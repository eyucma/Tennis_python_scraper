import re
import os
import pandas as pd
import numpy as np
import datetime

def n_set(x):
    col=['W'+str(i+1) for i in range(5)]+['L'+str(i+1) for i in range(5)]
    return 5-x[col].isna().sum()/2

def filter_high(x):
    if x['n_set']==5:
        return x['minutes']<=670
    else:
        return x['n_set']*90>x['minutes']


def repair_min(x, avg=40):
    """Crude corrector that can be improved"""
    if x['retirement']==True:
        return x['minutes']
    elif x['n_set']==5:
        if  x['minutes']<=670:
            return x['minutes']
        else:
            return x['n_set']*45
            
    else:
        if  (x['minutes']<=90*x['n_set']) and (x['minutes']>11*x['n_set']):
            return x['minutes']
        else:
            return x['n_set']*40
           


def cum_min_w(df):
    x=(df[['tourney_id','winner_id','match_num','minutes','loser_id']]).groupby(['tourney_id','winner_id'])
    l=[]
    w=[]
    for _,i in x:
        final=i.minutes.sum()
        y=i.loc[:,['tourney_id','winner_id']]
        y['l_min']=final
        y.rename(columns={'winner_id':'loser_id'}, inplace=True)
        l.append(y)
        i.loc[:,['minutes']]= i.minutes.cumsum()-i.minutes
        i.rename(columns={'minutes':'w_min'}, inplace=True)
        w.append(i)
    return l,w


if __name__ == '__main__':
    print('This file contains utility functions for cleaning of tennis data, and does nothing when run as a script')
    
    
    
    
    

