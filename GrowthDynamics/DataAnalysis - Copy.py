# -*- coding: utf-8 -*-
"""
Created on Sun Jul  1 15:40:37 2018

@author: brayd
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit

path = 'C:/Users/brayd/iGEM_2018/GrowthDynamics/BL21_GrowthData_1.txt'
comment_char = '#'

T, R1, R2 = np.loadtxt(path, usecols=(0,1,2), unpack=True, comments=comment_char)

plt.figure()
plt.title('Trial R1')
plt.scatter(T, R1, s=5)
plt.xlabel('Time (hours)')
plt.ylabel('OD')
plt.savefig('C:/Users/brayd/Desktop/BL21_growthcurve/Bl21_R1_1.png')

plt.figure()
plt.title('Trial R2')
plt.scatter(T, R2, s=5)
plt.xlabel('Time (hours)')
plt.ylabel('OD')
plt.savefig('C:/Users/brayd/Desktop/BL21_growthcurve/BL21_R2_1.png')

plt.figure()
plt.title('All Trials')
plt.scatter(T, R1, s=2, label = 'R1')
plt.scatter(T, R2, s=3, label = 'R2')
plt.xlabel('Time (hours)')
plt.ylabel('OD')
plt.legend()
plt.savefig('C:/Users/brayd/Desktop/BL21_growthcurve/BL21_AllTrials_1.png')

def model(x, a, b):
    return b*np.exp(a*x)

means = np.zeros(len(R1))
SEMs = np.zeros(len(R1))
for i in range(len(R1)):
    p = np.array([R1[i], R2[i]])
    mean = np.mean(p)
    means[i] = mean
    std = np.std(p)
    SEM = std/np.sqrt(len(p))
    SEMs[i] = SEM
    
plt.figure()
plt.title('Averaged Data')
plt.scatter(T, means, s=5)
plt.errorbar(T, means, yerr=SEMs, fmt='.', color='green', markersize=5)
plt.xlabel('Time (hours)')
plt.ylabel('OD')
plt.legend()
plt.savefig('C:/Users/brayd/Desktop/BL21_growthcurve/BL21_averageddata_1.png')

'''
#determine index of last negative value
neg = ([])
for i in range(len(means)):
    if means[i]<0:
        neg.append(i)
idx = max(neg)
print(idx)
#determine concavity via descretized 2nd derivative test
#to do: incorporate error
for i in range(idx+1,len(means)-2):
    m1 = means[i+1]-means[i]
    m2 = means[i+2]-means[i+1]
    if m1>0 and (m2<(m1-9*np.mean(SEMs[i:i+2]))): # this corresponds to negative concavity
        print(i)
        break
# need to consider convacity as an entensive property not instantaneous and thus consider change in slope trend over several consecutive indices
'''       

exp = means[0:13]
exp_err = np.zeros(len(exp))
exp_err.fill(np.mean(SEMs[0:13]))
T_exp = T[0:13]

p_opt, p_cov = curve_fit(model,T_exp, exp, sigma = exp_err)

plt.figure()
plt.title('Exponential Phase')
plt.scatter(T_exp, exp, s=5, label='Averaged Experimental Data',color='green')
plt.plot(T_exp, model(T_exp,*p_opt), label = 'Fitted Data')
plt.errorbar(T_exp, exp, yerr=exp_err, fmt='.', color='green', markersize=5)
plt.xlabel('Time (hours)')
plt.ylabel('OD')
plt.legend()
plt.savefig('C:/Users/brayd/Desktop/BL21_growthcurve/BL21_expPhase_1.png')

fitted_data = model(T_exp,*p_opt)
plt.figure()
plt.scatter(T_exp, (fitted_data-exp), s=5,color='green')
plt.errorbar(T_exp, (fitted_data-exp), yerr=exp_err, fmt='.', color='green', markersize=5)
plt.title('Residuals Plot')
plt.ylabel('Residuals, $y_{fitted}-y_{data}$')
plt.xlabel('Time (hours)')
plt.axhline(0, color='grey')
plt.savefig('C:/Users/brayd/Desktop/BL21_growthcurve/BL21_residuals_1.png')

#log_dat = np.log(exp)
plt.figure()
plt.title('Exponential Phase Semilogy')
plt.scatter(T_exp, exp, s=5,label='Averaged Experimental Data', color='green')
plt.semilogy(T_exp, model(T_exp,*p_opt),label = 'Fitted Data')
#plt.errorbar(T_exp, exp, yerr=exp_err, fmt='.', color='green', markersize=5)
plt.xlabel('Time (hours)')
plt.ylabel('log(OD)')
plt.legend()
plt.savefig('C:/Users/brayd/Desktop/BL21_growthcurve/BL21_semilogy_1.png')

from red_chi_squared import red_chi_squared
rcs = red_chi_squared(exp, fitted_data, exp_err, 2)
print('Reduced Chi Squared for Exponential fit is',str(rcs))
mu = p_opt[0]
fit_err = np.sqrt(p_cov[0,0])
print('The specific growth rate is', str(mu),'+/-', str(fit_err))


