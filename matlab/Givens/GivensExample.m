%% Givens Rotation Example for NSS-Based Yield Curve Factors
%
% MATLAB Version Compatibility:
%   - Developed and tested in MATLAB R2012a
%   - Fully compatible with MATLAB R2021a
%
% Required Toolboxes:
%   - Optimization Toolbox 
%       (required for fsolve and the Levenberg–Marquardt algorithm)
%   - Statistics Toolbox 
%       (required for PCA used in factor extraction)
%
% Notes:
%   This script constructs yields from Nelson–Siegel–Svensson (NSS) parameters,
%   extracts principal components as pricing factors, and applies a sequence of
%   Givens rotations to impose identification restrictions. The functions
%   NSS.m, MakeFactor.m, solve_phi_gen.m, and givens_rotation.m must be
%   available in the MATLAB path.
%
% _Jan Alsterlind 2025_

close;
clear;
clc;

% input data in time table format
LoadDat = load("SEbeta.mat");
InDat = LoadDat.MT_1;

Allbeta = [InDat.beta0 InDat.beta1 InDat.beta2 ...
   InDat.beta3 InDat.tau1 InDat.tau2];
text = cellstr(InDat.Time);

% assuming 4 factors
dim = 4;

%% Constructing yields and pricing factors ------------------------------
% Constructing pricing factors and data from NSS parameters 
 [last_obs, ~]=size(Allbeta); 
 AllMat=1/12:1/12:12;
 yzero=NaN(last_obs,length(AllMat));
 
% continous compounded yields, uses function NSS
 for ii=1:last_obs
  for kk=1:1:length(AllMat)
   yzero(ii,kk)=NSS(Allbeta(ii,:),AllMat(kk));    
  end
 end    
 
 % constructing factors
 [PC,Loadings] = MakeFactor(yzero,dim,0);

% choosing observable yields to estimate the model
 obsmat=[1 6 7 12 13 24 25 48 49 60 61 84 85 120 121 132 133];
 yy=yzero(:,obsmat)/1200;
   
 [n, o]=size(yy); 
 vecAll=Loadings(:,1:dim);
 
%% Rotating the factors and solving for restrictions --------------------
% We seek a dim X dim (dim=4 in this case) Givens rotation matrix
% 
% $$Q({\phi}_i) = 
% \pmatrix{1 & 0 & 0 & 0 \cr 0 & 1 & 0 & 0 \cr 0 & 0 & c_i & -s_i \cr 0& 0 & s_i & c_i}$$
% 
% where $c=cos({\phi}_i)$ and $s=sin({\phi}_i)$ and we solve for 
% the restrictions by numerical methods

 startv=[0.2 -0.2 0.3];
 phi=0.0;  % phi is redundant. However, it can't be any value as rotations 
               % and priors will be affected by this value            

 % for dim = 4 we choose these rotations (but others can work too)
 rot_i=[2 3 4 4];  
 rot_j=[1 1 1 3];

 % optimisation settings and the restrictions are solved numerically
 opts=optimset('Algorithm','levenberg-marquardt', ...
               'Display','off','MaxIter',1000, ...
               'MaxFunEvals',2000,'TolFun',1e-7,'TolX',1e-7);
 solveValues = ...
     fsolve(@solve_phi_gen,startv,opts,vecAll,phi,dim,rot_i,rot_j);
 
 radian=[solveValues phi];
 Smat=eye(dim); 
 for jj=1:dim
   GR = givens_rotation(radian(jj), dim, rot_i(jj), rot_j(jj));
   Smat = Smat*GR;
 end
 
F_rot=(PC*Smat');

% Re-scaling to match the short rate -----------------------------------
% Scaling to the level and volatility och the actual short yield 
 Yt=yzero(:,1);
 Zt=F_rot(:,1);
 [nobs,~]=size(Yt);
 Xt=[ones(nobs,1) Zt];
 b_hat=(Xt'*Xt)\(Xt'*Yt);
 fc1r=Xt*b_hat;

 % final factors
 fact = [fc1r F_rot(:,2:dim)];
 
 
 