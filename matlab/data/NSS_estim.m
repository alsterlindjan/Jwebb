%% File for SGB NSS-curve fitting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Uses different ways to estimate extended Nelson and Siegel (Svensson) 
% using Tbills (SSVX) and nominal coupon bonds (SGB)  
%
% Using function 
% a) LSQfit.m
% b) discflow.m
% c) NSS.m
%
%  _Jan Alsterlind 2026_
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 clear;
 clc;
 addpath(genpath(cd))
 
%% Choose method to estimate curve
method='ytm'; 
%method='obsyield'; 
%method='price';
%method='dur';
%method='dv01';

%% Data lake @ 2026-05-27 for mid-price trade day 2026-05-26
% Maturity = datenum({'17/06/2026','16/09/2026','12/11/2026','16/12/2026', ...
%                     '17/03/2027','12/05/2028','12/11/2029','12/05/2031', ...
%                     '01/06/2032','11/11/2033','11/05/2035','15/10/2036', ...
%                     '30/03/2039','24/11/2045', '23/06/2071'},'dd/mm/yyyy');
% Settle = datenum('28/05/2026','dd/mm/yyyy');
% Settle = repmat(Settle, length(Maturity), 1);
% coup=[0;0;1;0;0;0.75;0.75;0.125;2.25;1.75;2.25;2.5;3.5;0.5;1.375];
% PX_last=[99.89900;99.42800;99.56000;98.91000;98.38300;97.28600; ...
%          94.97500;89.57500;98.91300;94.67500;96.97600;97.97500; ...
%          107.34800;64.33300;58.75800];

Maturity = datenum({'17/06/2026','16/09/2026','12/11/2026','16/12/2026', ...
                    '17/03/2027','12/05/2028','12/11/2029','12/05/2031', ...
                    '01/06/2032','11/11/2033','11/05/2035','15/10/2036', ...
                    '30/03/2039','24/11/2045'},'dd/mm/yyyy');
Settle = datenum('28/05/2026','dd/mm/yyyy');
Settle = repmat(Settle, length(Maturity), 1);
coup=[0;0;1;0;0;0.75;0.75;0.125;2.25;1.75;2.25;2.5;3.5;0.5];
PX_last=[99.89900;99.42800;99.56000;98.91000;98.38300;97.28600; ...
         94.97500;89.57500;98.91300;94.67500;96.97600;97.97500; ...
         107.34800;64.33300];

[row, col]=size(Maturity);
[NumB,~]=size(Settle);
 
 % re-calculating to YTM definition or YTM and simple yield
 CalcYield=NaN(NumB,1);
 Dur=CalcYield; 
 for ii=1:1:NumB
 d = daysact(Settle(ii,:),Maturity(ii,:));
      y = 100 * bndyield(PX_last(ii), ...
      coup(ii)/100, ...
      Settle(ii,:), ...
      Maturity(ii,:), 1, 11);

 % to keep simpel yield definition for discount (act/360)    
 switch method
    case 'obsyield'
     if coup(ii)==0 && d < 365
       y = (100/PX_last(ii) - 1) * (360/d)*100;
     end 
 end 

 CalcYield(ii) = y;
 Dur(ii) = ...
     bnddury(CalcYield(ii)/100,coup(ii)/100,Settle(ii,:),Maturity(ii,:),1);
 end

% data end weights --------------------------------------------------------
switch method
    case {'ytm','obsyield'}
    data=CalcYield;    
    w=ones(numel(Dur),1);

    case 'price'
    data=PX_last;    
    w=ones(numel(Dur),1);

    case 'dur'
    data=PX_last;    
    w=(1 ./ ( Dur.^2 ));
    
    case 'dv01'
    data=PX_last;    
    w=(1 ./ ( (PX_last.*Dur).^2 ));
end


Set = datetime(Settle, 'ConvertFrom', 'datenum');
Mat = datetime(Maturity, 'ConvertFrom', 'datenum');

% settings for the disc function with continous yield, act/365
istep=1;                   %number of coupon payments
Face=100;                  %Face value
yrs=365;                   

%% Optim by non-linear least squares
 b=[3.0, 1.0, 1.0, 1.0, 1.0, 1.0];              %starting values
 lb=[-1, -100, -100, -100,  0.0001,  0.0001];     %lower bound
 ub=[ 10,  100,  100,  100, 50, 50];              %upper bound
 
 tic %starting timer for estimation
 options = optimoptions(@lsqnonlin, 'Algorithm', ...
     'trust-region-reflective', 'MaxFunEvals', 2000, 'MaxIter', 2000);
 [param] = ...
     lsqnonlin(@LSQfit,b,lb,ub,options,data,coup,Set,Mat,Face,istep,yrs,w,method);
 toc %stopping timer for estimation 


%% Results and graphs 
 DateNumber=(datenum(Mat)-datenum(Set))/yrs;
 spot=NaN(length(DateNumber),1);  

 for kk=1:length(DateNumber)
  spot(kk)=NSS(param,DateNumber(kk));
 end    


 switch method
  case 'ytm'
  [~, out]=LSQfit(param,data,coup,Set,Mat,Face,istep,yrs,w,method); 
  plot(DateNumber,out,'*',DateNumber,data,'o',DateNumber,spot,'-')
   title('Bond yields')
  legend('Estimated','Actual', 'Spot', ...
        'Location','Best','NumColumns',1)
  legend('boxoff');
  box on;
  axis tight;
  grid on
 
  case 'obsyield'
  [~, out]=LSQfit(param,data,coup,Set,Mat,Face,istep,yrs,w,method); 
  plot(DateNumber,out,'*',DateNumber,data,'o',DateNumber,spot,'-')
   title('Bond yields')
  legend('Estimated','Actual', 'Spot', ...
        'Location','Best','NumColumns',1)
  legend('boxoff');
  box on;
  axis tight;
  grid on
 
 case 'price'
 [~, out]=LSQfit(param,data,coup,Set,Mat,Face,istep,yrs,w,method); 
 yyaxis left
 plot(DateNumber,out,'*',DateNumber,data,'o')
 yyaxis right
 plot(DateNumber,spot,'-')
 title('Price')
 legend('Estimated','Actual', 'Spot', ...
        'Location','Best','NumColumns',1)
  legend('boxoff');
  box on;
  axis tight;
  grid on

 case 'dur'
 [~, out]=LSQfit(param,data,coup,Set,Mat,Face,istep,yrs,w,method); 
 yyaxis left
 plot(DateNumber,out,'*',DateNumber,data,'o')
 yyaxis right
 plot(DateNumber,spot,'-')
 title('Price, duration weighted')
 legend('Estimated','Actual', 'Spot', ...
        'Location','Best','NumColumns',1)
  legend('boxoff');
  box on;
  axis tight;
  grid on 

 case 'dv01'
 [~, out]=LSQfit(param,data,coup,Set,Mat,Face,istep,yrs,w,method); 
 yyaxis left
 plot(DateNumber,out,'*',DateNumber,data,'o')
 yyaxis right
 plot(DateNumber,spot,'-')
 title('Price, dv01 weighted')
 legend('Estimated','Actual', 'Spot', ...
        'Location','Best','NumColumns',1)
  legend('boxoff');
  box on;
  axis tight;
  grid on 


end

