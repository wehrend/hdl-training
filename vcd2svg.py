import sys,re,html
def parse(fn):
    ids={};vals={};t=0;width={}
    txt=open(fn).read()
    scope=[]
    for m in re.finditer(r'\$var\s+\w+\s+(\d+)\s+(\S+)\s+(\S+)(?:\s+\[[^\]]*\])?\s+\$end',txt):
        w,i,n=m.groups(); ids.setdefault(i,[]).append(n); width[i]=int(w)
    body=txt.split('$enddefinitions')[1]
    ch={i:[] for i in ids}
    for line in body.split('\n'):
        line=line.strip()
        if not line or line.startswith('$'): continue
        if line[0]=='#': t=int(line[1:]); continue
        if line[0] in 'bB':
            v,i=line[1:].split(); ch[i].append((t,v))
        elif line[0] in '01xXzZ':
            ch[line[1:]].append((t,line[0]))
    return ids,width,ch,t
def render(fn,out,signals,tend=None,scale=None,unit=1000,label_unit='ns',tick=20):
    ids,width,ch,tmax=parse(fn)
    tend=tend or tmax
    name2id={}
    for i,ns in ids.items():
        for n in ns: name2id.setdefault(n,i)
    L=70; W=780; rowh=34; sigh=18
    sx=(W-L-25)/tend
    H=len(signals)*rowh+40
    o=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" font-family="sans-serif">',
       '<style>.w{fill:none;stroke:black;stroke-width:1.2}.b{fill:lightskyblue;stroke:black;stroke-width:1}.g{stroke:#ccc;stroke-width:0.6;stroke-dasharray:2,3}</style>']
    # grid + axis
    for tt in range(0,tend+1,tick*unit):
        x=L+tt*sx; o.append(f'<line class="g" x1="{x:.1f}" y1="10" x2="{x:.1f}" y2="{H-25}"/>')
        o.append(f'<text x="{x:.1f}" y="{H-10}" font-size="10" text-anchor="middle">{tt//unit}</text>')
    o.append(f'<text x="5" y="{H-10}" font-size="10">t / {label_unit}</text>')
    for r,sig in enumerate(signals):
        name,disp=sig[0],sig[1]; fmt=sig[2] if len(sig)>2 else 'd'
        i=name2id[name]; y0=20+r*rowh; yh=y0; yl=y0+sigh; ym=y0+sigh/2
        o.append(f'<text x="5" y="{ym+4}" font-size="12">{html.escape(disp)}</text>')
        evs=[(t,v) for t,v in ch[i] if t<=tend]
        if width[i]==1:
            pts=[];prev=None
            for k,(t,v) in enumerate(evs):
                x=L+t*sx; y={'1':yh,'0':yl}.get(v,ym)
                if prev is None: pts.append((x,y))
                else: pts.append((x,prev)); pts.append((x,y))
                prev=y
            pts.append((L+tend*sx,prev))
            o.append('<polyline class="w" points="'+' '.join(f'{x:.1f},{y:.1f}' for x,y in pts)+'"/>')
            for k,(t,v) in enumerate(evs):
                if v.lower() in 'xz':
                    t2=evs[k+1][0] if k+1<len(evs) else tend
                    x1=L+t*sx; x2=L+t2*sx
                    o.append(f'<rect x="{x1:.1f}" y="{yh}" width="{x2-x1:.1f}" height="{sigh}" style="fill:#e0e0e0;stroke:none"/>')
                    if x2-x1>12: o.append(f'<text x="{(x1+x2)/2:.1f}" y="{ym+4}" font-size="10" text-anchor="middle">x</text>')
        else:
            segs=[]
            for k,(t,v) in enumerate(evs):
                t2=evs[k+1][0] if k+1<len(evs) else tend
                if t2>t: segs.append((t,t2,v))
            # merge equal consecutive
            m=[]
            for s in segs:
                if m and m[-1][2]==s[2]: m[-1]=(m[-1][0],s[1],s[2])
                else: m.append(s)
            for t1,t2,v in m:
                x1=L+t1*sx; x2=L+t2*sx; d=min(3,(x2-x1)/2)
                isx='x' in v.lower() and (fmt!='b' or set(v.lower())=={'x'})
                fill='#eee' if isx else 'lightskyblue'
                o.append(f'<polygon points="{x1:.1f},{ym} {x1+d:.1f},{yh} {x2-d:.1f},{yh} {x2:.1f},{ym} {x2-d:.1f},{yl} {x1+d:.1f},{yl}" style="fill:{fill};stroke:black;stroke-width:1"/>')
                txt=(v.rjust(width[i], v[0] if v[0].lower() in 'xz' else '0') if fmt=='b' else ('x' if isx else (format(int(v,2),'x') if fmt=='h' else (str(int(v,2)-(1<<width[i]) if fmt=='s' and int(v,2)>>(width[i]-1) else int(v,2))))))
                if x2-x1>12: o.append(f'<text x="{(x1+x2)/2:.1f}" y="{ym+4}" font-size="10" text-anchor="middle">{txt}</text>')
    o.append('</svg>')
    open(out,'w').write('\n'.join(o))
if __name__=='__main__':
    pass
