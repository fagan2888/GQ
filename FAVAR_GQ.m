%FAVAR CODE

clear all;
clc;

%% USER INPUT

% Select a subset of the 6 variables in Y

subset = 2;     % 1: DF1, DF2 (2 vars)
                % 2: DF1, DF2, FFR (3 vars)
                % 3: Indus. Prod., Inflation CPI, S&P 500, 10Y TB, DF1, DF2 (6 vars)

%% DATA

% ----- LOAD DATA -----
% X : factors 
xdata = xlsread('data.xlsx','X until 2007');
% Y 
ydata = xlsread('data.xlsx','Y until 2007');

if subset == 1
    ydata = ydata(:,[1 2]);
elseif subset == 2
    ydata = ydata(:,[1 2 3]);
elseif subset == 3
    ydata = ydata(:,[1 2 3 4 5 6]);  
end

% Slow/Fast
slowcode = xlsread('data.xlsx','slow 2007');
% Dates
yearlab = xlsread('data.xlsx','year until 2007');
% Names de X
[~,namesX] = xlsread('data.xlsx','name 2007');
if subset == 1
    stddata = [std(xdata) ones(1,2)];
elseif subset == 2
    stddata = [std(xdata) ones(1,3)];
elseif subset == 3
    stddata = [std(xdata) ones(1,6)];
end


% Size
t1 = size(xdata,1);    
t2 = size(ydata,1);  

% ----- Description de Y (Graphiques) -----

% US Speculative-Grade Default Rates
figure(1)
plot(yearlab,ydata(:,1),'Color','black','LineWidth',2);
xlim([2000 yearlab(t2)]);
grid on;
hxlabel = 'Time';
hylabel = 'US Speculative-Grade Default Rates';

% Issuer-Weighted Speculative-Grade US Bond 
figure(2)
plot(yearlab,ydata(:,2),'Color','black','LineWidth',2);
xlim([2000 yearlab(t2)]);
grid on;
hxlabel = 'Time';
hylabel = 'Issuer-Weighted Speculative-Grade US Bond ';

% Fed Funds Rate
figure(3)
plot(yearlab,ydata(:,3),'Color','black','LineWidth',2);
xlim([2000 yearlab(t2)]);
grid on;
hxlabel = 'Time';
hylabel = 'Fed Funds Rate';

% ----- First test de stationnarité ADF ----- 
% Y
for i = 1:size(ydata,2)
    [hY1(i),pval1(i)] = adftest(ydata(:,i), 'model','ts', 'lags',2);
end 
    %[hY1,pval1] = adftest(ydata, 'model','ts', 'lags',2)
% X 
for i = 1:size(xdata,2)
    [hY2(i),pval2(i)] = adftest(xdata(:,i), 'model','ts', 'lags',2);
end 

% Transformation de X
% Pas de transformation ici vu qu'on a dl déjà transformé
% trans = xlsread('data.xlsx','trans 2007');
% Transform data to be approximately stationary
%for i_x = 1:size(xdata,2)   % Transform "X"
%    xtempraw(:,i_x) = transx(xdata(:,i_x),tcode(i_x)); %#ok<AGROW>
%end

% Transformation de Y : ici, au lieu de prendre par différnce, j'ai pris
% par log

for i_y = 1:size(ydata,2)
    ytempraw(:,i_y) = transx(ydata(:,i_y),5);
end

%ydata = xlsread('data.xlsx','Feuil1');
%ytempraw = transx(ydata,2);

% Correct size after stationarity transformation
%xdata = xtempraw;
ydata = ytempraw;

% Test de stationnarité DF
% Y
for i = 1:size(ydata,2)
    [hY2(i),pval2(i)] = adftest(ydata(:,i), 'model','ts', 'lags',2);
end 
%[hY2,pval2] = adftest(ydata, 'model','ts', 'lags',2)
% X

% Demean data (no intercept is estimated as in BBE (2005)) 
xdata = (xdata - repmat(mean(xdata,1),t1,1));
ydata = (ydata - repmat(mean(ydata,1),t2,1));

% Define X et Y
X = xdata;   % Factors
Y = ydata; % Y 
namesXY = [namesX ; 'Moodys 1' ; 'Moodys 2'; 'FFR']; % Noms


% Number of observations and dimension of X and Y
T=size(Y,1); % T time series observations
N=size(X,2); % N series from which we extract factors
M=size(Y,2); 

