%Runs a simple Metropolis-Hastings (ie MCMC) algoritm to simulate two 
%jointly distributed random variuables with probability density
%p(x,y)=80*exp(-(x^2+y^2)/s^2)+100*exp(-(x^2+y^2)/s^2), where s>0.
%
%Author: H. Paul Keeler, 2019.

clearvars;clc;close all;

%Simulation window parameters
xMin=-1;xMax=1;
yMin=-1;yMax=1;

simNumb=10^5; %number of random variables simulated
numbSteps=30; %number of steps for the Markov process
numbBins=25; %number of bins for histogram
sigma=2; %standard deviation for normal random steps

%probability density parameters
s=.4; %scale parameter for distribution to be simulated
fun_lambda=@(x,y)(80*exp(-((x+0.5).^2+(y+0.5).^2)/s^2)+100*exp(-((x-0.5).^2+(y-0.5).^2)/s^2));
%normalization constant
consNorm=integral2(fun_lambda,xMin,xMax,yMin,yMax);
fun_p=@(x,y)((fun_lambda(x,y)/consNorm).*(x>=xMin).*(y>=yMin).*(x<=xMax).*(y<=yMax));

xRand=(xMax-xMin)*rand(simNumb,1)+xMin; %random intial values
yRand=(yMax-yMin)*rand(simNumb,1)+yMin; %random intial values

probCurrent=fun_p(xRand,yRand); %current transition probabilities

for jj=1:numbSteps
    zxRand= xRand +sigma*randn(size(xRand));%take a (normally distributed) random step
    zyRand= yRand +sigma*randn(size(yRand));%take a (normally distributed) random step
    %Conditional random step needs to be symmetric in x and y
    %For example: Z|x ~ N(x,1) (or Y=x+N(0,1)) with probability density
    %p(z|x)=e(-(z-x)^2/2)/sqrt(2*pi)
    probProposal=fun_p(zxRand,zyRand); %proposed probability
    
    %acceptance-rejection step
    booleAccept=rand(simNumb,1) < probProposal./probCurrent;
    %update state of random walk/Markov chain
    xRand(booleAccept)=zxRand(booleAccept);
    yRand(booleAccept)=zyRand(booleAccept);

    %update transition probabilities
    probCurrent(booleAccept,:)=probProposal(booleAccept,:);
    
end

%Histogram section: empirical probability density
[p_Estimate,xxEdges,yyEdges]=histcounts2(xRand,yRand,numbBins,'Normalization','pdf');
xValues=(xxEdges(2:end)+xxEdges(1:end-1))/2; %mid-points of bins
yValues=(yyEdges(2:end)+yyEdges(1:end-1))/2; %mid-points of bins
[X, Y]=meshgrid(xValues,yValues); %create x/y matrices for plotting

%analytic solution of probability density
p_Exact=fun_p(X,Y);

%Plotting
%Plot empirical estimate
figure;
surf(X,Y,p_Estimate); colormap spring; axis tight;
xlabel("x"); ylabel("y");
title('p(x,y) Estimate');

%Plot exact expression
figure;
surf(X,Y,p_Exact);  colormap spring; axis tight;
xlabel("x"); ylabel("y");
title('p(x,y) Exact expression');
