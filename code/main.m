addpath('utils')
clear all; close all; clc;

% put all the studies together and preprocess the data
preprocess_create_master_table()

% weighted, flexible-degree polynomial fitting to estimate scatter (+model-free bin estimates)
estimate_polynomial_mvav()

% summarize the datasets
table1()

% create figures
figure2()
figure3A()
figure3B_S7()
figure4()
figureS1()
figureS2to5()
figureS6()

% stats using LMMs
linear_mixed_models()