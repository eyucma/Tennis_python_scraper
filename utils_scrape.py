import urllib.request
import re
import os
import pandas as pd
import numpy as np
from collections import defaultdict
import datetime


def parser_csv(repo,exclude=["atp_matches_doubles_yyyy.csv"]):
    f=urllib.request.urlopen(repo)
    mb=f.read()
    str_rep=mb.decode("utf8")
    f.close()
    files=list(set(re.findall('\\w+?\\.csv',str_rep)))
    return ([i for i in files if i not in exclude])


def fetch_data(links,prefix=None,**kwargs):
    l = [os.path.join(prefix,re.sub(r'^/', '',file, count=1)) for file in links]
    urls = [re.sub(r'.blob', '',file, count=1) for file in l]
    dfs=[]
    for i in range(len(urls)):
        #print(i), for debugging
        dfs.append(pd.read_csv(urls[i],**kwargs))
    return pd.concat(dfs, ignore_index=True)

def date_cleaner(x, tag):
    if pd.isna(x[tag]):
        x['year_invalid']=True
        x['month_invalid']=True
        x['day_invalid']=True
        return x
    
    if not bool(re.search(r'^\d{8}$|\d{4}/\d{2}/\d{2}', x[tag])):
        x['year_invalid']=True
        x['month_invalid']=True
        x['day_invalid']=True
        return x
 
    try:
        x[tag]=datetime.datetime.strptime(x[tag], '%Y%m%d').strftime('%Y/%m/%d')
        return x
        
    except ValueError:
        if bool(re.search(r'^[3-9]', x[tag])):
            x[tag]=re.sub(r'^[3-9]',r'1', x[tag])
            x['year_invalid']=True
            
        if bool(re.search(r'^2[1-9]', x[tag])):
            x['year_invalid']=True
        
        if bool(re.search(r'^20[3-9]', x[tag])):
            x['year_invalid']=True
    
        if bool(re.search(r'\d{4}0{2}\d{2}', x[tag])):
            x[tag]=re.sub(r'(\d{4})0{2}(\d{2})',r'\g<1>01\2', x[tag])
            x['month_invalid']=True

        if bool(re.search(r'\d{4}[2-9]\d{3}', x[tag])):
            x[tag]=re.sub(r'(\d{4})[2-9](\d{3})',r'\g<1>0\2', x[tag])
            x['month_invalid']=True
        if bool(re.search(r'\d{4}1[3-9]\d{2}', x[tag])):
            x[tag]=re.sub(r'(\d{4})1([3-9])(\d{2})',r'\g<1>0\2\3', x[tag])
            x['month_invalid']=True

        if bool(re.search(r'\d{6}0{2}', x[tag])):
            x[tag]=re.sub(r'(\d{6})00',r'\g<1>01', x[tag])
            x['day_invalid']=True

        if bool(re.search(r'\d{6}[4-9]\d', x[tag])):
            x[tag]=re.sub(r'(\d{6}[4-9](\d)',r'\g<1>0\2', x[tag])
            x['day_invalid']=True

        if bool(re.search(r'\d{6}3[2-9]', x[tag])):
            x[tag]=re.sub('(\d{6})3([2-9])',r'\g<1>0\2', x[tag])
            x['day_invalid']=True
        
        try:
            x[tag]=datetime.datetime.strptime(x[tag], '%Y%m%d').strftime('%Y/%m/%d')
            return x
        except ValueError:
            x['year_invalid']=True
            x['month_invalid']=True
            x['day_invalid']=True
            return x
    
def sc_clean(score):
    t=str(score)
    t=re.sub(r'[A-Za-z]',r'', t) #Removes ret and other texts
    t=re.sub(r'[%?>!:;&.]',r'', t) #Removes nonsense

    t=re.sub(r' {2,}',r' ', t) #Removes extra blanks
    t=re.sub(r'^ | $',r'',t)  #----"----

    t=re.sub(r'(\d)0(\d)', r'\g<1>-\g<2>',t) #Deals with some weird formatting in the form 706 401 604 etc.
    
    #Removing random spaces in the middle
    for i in range(5):
        a=re.sub(r'(-\d{1,2})(\(\d{1,2}\))? (\d) (\d)',r'\g<1>\g<2> \g<3>-\g<4>', t)
        if a==t:
            break 
        else:
            t=a

    t=re.sub(r'^(\d) (\d)',r'\g<1>-\g<2>', t) #Removing gaps in the beginning
    t=re.sub(r'^(\d) -',r'\g<1>-', t) # -----"-----
    
    for i in range(5):
        a=re.sub(r'(-\d{1,2})(\(\d{1,2}\))? (\d) ',r'\g<1>\g<2> \g<3>', t)
        if a==t:
            break 
        else:
            t=a
            
    t=re.sub(r' (\d)(\d)(\(\d{1,2}\))?',r' \1-\2\3', t) #Inserts hyphen for random missing 
    t=re.sub(r'(\d)(\d)(\(\d{1,2}\))? ',r'\1-\2\3 ', t) # ----"---- at start  
        
    t=re.sub(r'[^\d\)\] ]$', r'',t) #Removes blanks and punct at the end
    
    t=re.sub(r' {2,}',r' ', t) #Removes extra blanks
    t=re.sub(r'^ | $',r'',t)  #----"----
    return t

def ret_parser(score):
    t=str(score)
    return bool(re.search(r'[A-Za-z].[A-Za-z]', t)) or bool(re.search(r'[A-Za-z][A-Za-z]', t))

def games_ext(score):
    """Extracts the games won from each set, score has to be a list or series like structure"""
    nan='nan'
    games=[]
    for i in range(len(score)):
        x=re.sub(r'\(\d{1,2}\)','',str(score[i]))
        x=re.sub(r'\[\d{1,2}-\d{1,2}\]','1-0',x).split(' ') ##Accounts for tiebreak final set in tournaments like the Laver Cup
        x=[i for i in x if i!='']
        n=len(x)
        if n==0:
            games.append(10*[nan])
            continue
        y=[j.split('-') for j in x]
        try: 
            g_w=[j[0] for j in y]
            g_l=[j[1] for j in y]
        except:
            print(f'Error at {i}, with:',y)
        games.append(g_w+(5-n)*[nan]+g_l+(5-n)*[nan])
        try:
            assert len(games[-1])==10
        except:
            print(f'Error at {i}, with:',y)
    return games

def TB_ext(score):
    """Extracts the number of points won during tiebreakers, score has to be a dataframe structure with tourney_date and tourney_name. Luckily the data from JeffSackmann does not record 9 point Tiebreaks which were used in the US Open from 1970 until 1974 (most online databases do not record these scores either), however the 10 point tiebreaker was implemented in AO 2019 and 2020 for all GS."""
    nan='nan'
    pts=[]
    for i in range(len(score)):
        x=re.sub(r'\d{1,2}-\d{1,2} ','N ',str(score[i]))
        x=re.sub(r'\d{1,2}-\d{1,2}$','N',x)
        x=re.sub(r'\[(\d{1,2})-(\d{1,2})\]','\1-\2',x).split(' ') ##Accounts for tiebreak final set in tournaments like the Laver Cup
        x=[i for i in x if i!='']
        n=len(x)
        if n==0:
            games.append(10*[nan])
            continue
        p_w=[]
        p_l=[]
        for i in range(n):
            #Deal with tiebreakers is tedious because the various different formats throughout history, if data is relatively recent it would be musch simpler.
            try:
                if len(x[i])<2:
                    assert x[i]=='N'
                    p_w.append(0)
                    p_l.append(0)
                elif bool(re.search(r'\d{1,2}-\d{1,2}', x[i])):
                    y=x[i].split('-')
                    p_w.append(int(y[0]))
                    p_l.append(int(y[1]))
                else:
                    assert bool(re.search(r'\(\d{1,2}\)', x[i]))
                    
                    
            except:
                print(f'Error at {i}, with:',x)
        games.append(g_w+(5-n)*[nan]+g_l+(5-n)*[nan])
        try:
            assert len(games[-1])==10
        except:
            print(f'Error at {i}, with:',y)
    return games


if __name__ == '__main__':
    print('This file contains utility functions for web-scraping of tennis data, and does nothing when run as a script')
    
    
    
    
    

