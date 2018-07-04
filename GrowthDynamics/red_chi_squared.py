# -*- coding: utf-8 -*-
"""
Created on Mon Jul  2 12:11:41 2018

@author: brayd
"""
import numpy as np
'''
Function for calculating reduced chi squared as a stastical measure of goodness of fit when
curve fitting. y is experimental data in an array, fitted_data is model fit function evaluated at x array 
for optimized parameters, sigma is error in y, n is degrees of freedom(i.e. number of fit parameters)
'''
def red_chi_squared(y, fitted_data, sigma, n):
    return sum(((y-fitted_data)/sigma)**2)/(np.size(y)-n)