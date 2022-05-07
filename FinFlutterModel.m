%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Fin Flutter Model %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% As taken from:
%   https://www.apogeerockets.com/education/downloads/Newsletter411.pdf
% with an atmospheric pressure and temperature model from NASA and ideal
% gas law for atmospheric speed of sound

clc     %Clear Command Window
clear   %Clear Variables

%%% Material Properties %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Young modulus of G10 fiberglass composite as found by
%  Ravi-Chandar, K., and S. Satapathy. "Mechanical properties of G-10
%  glass-epoxy composite." Defense Technical Information Center (2007).
    E = 18.8E9;                %[Pa]
    poisson = 0.3;
    
%Shear modulus based on isotropic material approximation (best
%approximation I could find)
    G = E/(2*(1+poisson));     %[Pa]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Geometric Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Inputs:
    Cr = 0.408;         %[m] Root Chord
    Ct = 0.2097;        %[m] Tip Chord
    b = 0.114;          %[m] Fin Height
    t = 1/4*0.0254;     %[m] Fin Thickness (original = 0.15" = 0.00381m)

%Calculations:
    S = (b/2)*(Cr+Ct);  %[m2] Fin Area
    lambda = Ct/Cr;     %[] Fin taper Ratio
    B = b^2/S;          %[] Aspect ratio
    tn = t/Cr;          %[] Normalized Thickness
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%%% Atmospheric Model %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Constants:
    h = [0:1:8000]; %[m] Array of Rocket Altitude
    Po = 101300;    %[Pa] Sea Level Pressure
    H = 8077;       %[m] Atmospheric Scale Height
    ga = 1.4;       %[] Specific Heat Ratio for Air
    R = 287.05;     %[Nm/(kgK)] Perfect gas Constant for Air
    
%Calculations:
    T = (15.04-0.00649*h)+273.15;           %[K] Atmospheric Temperature
    P = (101.29*((T)/288.02).^(5.256))*1000;%[Pa] Atmospheric Pressure
    a = (ga*R*T).^(1/2);                    %[m/s] Atmospheric Sound Speed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Import Altitude and Velocity Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%importing values into imported
    %[Altitude,Vel] = ...
    %importfile('Rocket_Positionv_v_Speed.xlsx','Export Data',1,354);
    %xlsread('Rocket_Positionv_v_Speed_v2.xlsx', , 2, 354);
    Data = load("workspace variables.mat",'s','v');
    Altitude = Data.s(2,:);
    Vel = sqrt(Data.v(1,:).^2 + Data.v(2,:).^2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%%% Flutter Predictions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Empirical Formula for Flutter Prediction (NACA Technical Paper 4197)
    Vf = 1.223*(a.*((Po./P).^(1/2)))*...
        ((G/Po)^(1/2))*((((tn/B)^3)*((2+B)/(1+lambda)))^(1/2)); %[m/s]

%Plot:
     plot(h, Vf,Altitude,Vel,...
         'linewidth',2)
     grid on
     legend('Flutter Boundary','Predicted Velocity')
     xlabel('Altitude [m]')
     ylabel('Velocity [m/s]')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Safety Factor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Find maximum speed of the rocket
    [maxV,index] = max(Vel);

%Find the corresponding index in the array of flutter altitudes h
    [~,Vfindex] = min(abs(Altitude(index)-h));

%Calculate the safety Factor
    safetyFactor = Vf(Vfindex)/maxV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
