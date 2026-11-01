"""Reproduce the factual IV/V source extraction (temporary files, no DB writes).

Requires pypdf. The source manual is downloaded to the system temporary directory;
copyrighted prose and the source PDF are not committed to the repository.
"""
import concurrent.futures
import html
import json
from pathlib import Path
import re
import tempfile
import urllib.request

from pypdf import PdfReader

CACHE = Path(tempfile.gettempdir()) / 'heroeswatch-homm45-research'
CACHE.mkdir(exist_ok=True)
MANUAL = 'https://h5.heroes.net.pl/uploaded/download/other/Heroes5-Manual-en-3-1.pdf'
if not (CACHE / 'homm5.pdf').exists():
    (CACHE / 'homm5.pdf').write_bytes(urllib.request.urlopen(MANUAL).read())
reader = PdfReader(CACHE / 'homm5.pdf')
buildings = []
heroes = []
dwellings = []
faction = None
for page_num in range(11, 70):
    page = reader.pages[page_num - 1]
    text = page.extract_text()
    bold_names = []
    page.extract_text(visitor_text=lambda t,cm,tm,f,s: bold_names.append(t.strip()) if f and 'Bold' in f.get('/BaseFont','') else None)
    match = re.search(r'(Academy|Dungeon|Fortress|Haven|Inferno|Necropolis|Stronghold|Sylvan) Heroes', text)
    if match:
        faction = match[1]
    for match in re.finditer(r'^([A-Za-z][A-Za-z \'-]+) - ([^\n]+)$', text, re.M):
        if match[1] not in bold_names:
            continue
        heroes.append({'name': match[1], 'specialty': match[2], 'faction': faction,
                       'campaign': 'Heroes - Campaign' in text, 'page': page_num})
for page_num in range(211, 243):
    chunks = []
    reader.pages[page_num - 1].extract_text(visitor_text=lambda t,cm,tm,f,s: chunks.append((t, f.get('/BaseFont', '') if f else '', s)))
    for index, (text, font, size) in enumerate(chunks):
        text = text.strip()
        match = re.match(r'(Academy|Dungeon|Fortress|Haven|Inferno|Necropolis|Stronghold|Sylvan) Buildings', text)
        if match:
            faction = match[1]
        if 'Bold' in font and size == 8 and text and re.match('[A-Za-z]', text) and text not in ['Cost:', 'Requires:']:
            tail = ''.join(t + '\n' for t,_,_ in chunks[index+1:index+40])
            next_title = next((i for i, (t,f,s) in enumerate(chunks[index+1:]) if 'Bold' in f and s == 8 and re.match('[A-Za-z]',t.strip()) and t.strip() not in ['Cost:','Requires:']), None)
            if next_title is not None:
                tail = ''.join(t + '\n' for t,_,_ in chunks[index+1:index+1+next_title])
            level = re.search(r'Town Level (\d+)', tail)
            dwelling = re.search(r'Dwelling Level (\d+)', tail)
            buildings.append({'name': text, 'faction': faction, 'page': page_num,
                              'townLevel': int(level[1]) if level else None,
                              'dwellingTier': int(dwelling[1]) if dwelling else None,
                              'grail': 'Grail Structure' in tail})
for page_num in [266,267,268]:
    chunks = []
    reader.pages[page_num - 1].extract_text(visitor_text=lambda t,cm,tm,f,s: chunks.append((t, f.get('/BaseFont', '') if f else '', s)))
    for text,font,size in chunks:
        if text == 'Mines':
            break
        if 'Bold' in font and size == 8 and text.strip():
            dwellings.append(text.strip().rstrip('.'))
(CACHE / 'h5-extracted.json').write_text(json.dumps({'heroes': heroes, 'buildings': buildings, 'dwellings': dwellings},indent=2),encoding='utf-8')

def fetch_h4(kind):
    url = 'https://www.ringofsaturn.com/games/heroes4/buildings_' + kind + '.shtml'
    source = urllib.request.urlopen(url).read().decode()
    rows = []
    section = 'Standard Buildings'
    for match in re.finditer(r'<h3>(.*?)</h3>|<table class="building">(.*?)</table>',source,re.S):
        if match[1]:
            section = match[1]
        else:
            body = match[2]
            title = html.unescape(re.search(r'<b>(.*?)</b>',body,re.S)[1]).strip()
            rows.append({'name':title,'section':section,'choice':'prevents the construction' in body})
    return kind,rows
h4 = dict(concurrent.futures.ThreadPoolExecutor().map(fetch_h4,['life','order','death','chaos','nature','might']))
(CACHE / 'h4-buildings.json').write_text(json.dumps(h4,indent=2),encoding='utf-8')
print(json.dumps({'h5': {'heroes':len(heroes),'buildings':len(buildings),'dwellings':len(dwellings)},'h4Buildings':{k:len(v) for k,v in h4.items()}}))
