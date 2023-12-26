%% Test code in class

clc
clear all

close all

%% Conditions for rainy road
Gain = 500000;
InitSpeed = 50; 
decelLim = -150;


numSteps = 100;
P = [0.6 0.4; 0.85 0.15];

mc = dtmc(P);

scenario = simulate(mc,numSteps); % 2 is HCW, 1 is LCW

HilHipMethod

