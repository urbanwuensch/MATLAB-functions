function [ dataout ] = redoXMcorrection( datain , details)
% <strong>Correction EEMs with outdated or otherwise fautly X- and Mcor files</strong>
% This function first reverts the faulty correction, then applies a correct
% one.
% For it to do its job, it needs the faulty and correct Xcor and Mcor
% information. How you get it is up to you & that is instrument-specific. I
% cannot help you there. Once you have Xcor and Mcor, plug in the
% information in L31-36. You may have noticed that the function itself
% contains the correction factors, they are not provided with inputs. Both
% undone and reapplied Xcor and Mcor are stored in dataout so you can undo
% your work at any point in time.
%
% <strong>IMPORTANT</strong> This function assumes that Xcor and Mcor are multiplied onto
% an EEM. Faulty corrections are undone by dividing each EEM by the faulty
% factors, the reapplcation of correct factors is done by multiplication.
% 
% The proper functioning of this methodology was verified only with an
% HORIBA AquaLog. Every user must ensure that the code works for their
% specific case. Consult the instrument manual.
%
% <strong>USEAGE</strong>
%           [ dataout ] = XMcorrect( data)
%
% <strong>INPUTS</strong>
%               datain:           drEEM-format dataset (.X, .Em, .Ex are needed)
%               details:          true | false. Want some more visual info?
%
% <strong>OUTPUTS</strong>
%               dataout:          drEEM-format dataset, corrected EEMs
%
% <strong>Examples</strong>
%       [Xout] = XMcorrect(Xin,time)
%
% (c) Urban Wünsch, DTU Aqua (urbw@aqua.dtu.dk) & Chalmers University of Technology (wuensch@chalmers.se)
%
% <strong>History</strong>
% Version 1.0: Version 1.0, 10-03-2016: First draft of function
% Version 1.1: Version 1.0, 08-22-2016: Added functionality
% Version 1.2: Version 1.1, 25-03-2020, Lots of improvements, removed some features for first version on GitHub
%
%
% (c) <strong>Urban Wünsch</strong>, <strong>DTU Aqua</strong> (urbw@aqua.dtu.dk) & <strong>Chalmers University of Technology</strong> (wuensch@chalmers.se)



if isfield(datain,'XMcorrected')
    disp('Function already applied. You may continue with whatever it is that you''re doing with your life...');
    return;
end

%% correct and faulty Xcor and Mcor
mcor_correct=[213.4240,1;216.5960,1;219.7710,1;222.9480,1;226.1270,1;229.3090,1;232.4930,1;235.6790,1;238.8680,1;242.0590,1;245.2530,1;248.4490,1;251.6470,1.184340;254.8470,1.1407;258.05,1.123850;261.2550,1.116460;264.4620,1.128580;267.671,1.14438;270.883,1.14121;274.097,1.13361;277.313,1.11617;280.531,1.10247;283.751,1.07990;286.973,1.06046;290.198,1.04686;293.424,1.02802;296.653,1.01310;299.884,1.00982;303.117,0.995940;306.351,0.983410;309.588,0.969340;312.827,0.963730;316.068,0.958510;319.311,0.972830;322.556,0.984640;325.802,0.990870;329.051,0.999260;332.301,1.00457;335.554,1.00564;338.808,1.00639;342.064,1.00739;345.322,1.01;348.582,1.01923;351.844,1.02944;355.107,1.03626;358.372,1.04354;361.639,1.05064;364.908,1.05518;368.178,1.05618;371.450,1.05043;374.724,1.05432;378,1.03215;381.277,1.01782;384.555,1.00689;387.836,0.992450;391.118,0.968930;394.401,0.963960;397.686,0.946490;400.973,0.932750;404.261,0.924040;407.551,0.914600;410.842,0.897460;414.134,0.888590;417.429,0.876030;420.724,0.859830;424.021,0.851560;427.319,0.836100;430.619,0.829100;433.920,0.823580;437.222,0.820190;440.526,0.815710;443.831,0.807950;447.137,0.799570;450.445,0.790550;453.754,0.785310;457.064,0.783630;460.375,0.782030;463.687,0.777510;467.001,0.769450;470.316,0.762190;473.631,0.760680;476.948,0.757070;480.266,0.755400;483.585,0.758290;486.906,0.757590;490.227,0.760100;493.549,0.759540;496.872,0.759140;500.196,0.754810;503.521,0.739960;506.847,0.726030;510.174,0.714970;513.502,0.713670;516.831,0.725570;520.160,0.739300;523.491,0.744680;526.822,0.733890;530.154,0.717920;533.486,0.708670;536.820,0.710390;540.154,0.722720;543.489,0.740150;546.825,0.751250;550.161,0.752390;553.498,0.745650;556.835,0.735930;560.173,0.733840;563.512,0.736180;566.851,0.747600;570.191,0.763760;573.531,0.769110;576.872,0.768710;580.213,0.762220;583.554,0.750850;586.896,0.744660;590.239,0.744860;593.582,0.751180;596.925,0.765430;600.268,0.777;603.612,0.786830;606.956,0.792860;610.301,0.793970;613.645,0.791790;616.990,0.788810;620.335,1];
xcor_correct=[600,0.709630;595,0.712460;590,0.716010;585,0.719120;580,0.721500;575,0.724530;570,0.728580;565,0.732620;560,0.736710;555,0.741490;550,0.746910;545,0.752310;540,0.757440;535,0.763440;530,0.770140;525,0.776980;520,0.784240;515,0.792080;510,0.800500;505,0.808680;500,0.816450;495,0.824280;490,0.830290;485,0.839660;480,0.851050;475,0.863700;470,0.877870;465,0.892450;460,0.905560;455,0.914830;450,0.920070;445,0.924930;440,0.931780;435,0.941300;430,0.953520;425,0.970220;420,0.986630;415,0.998240;410,1.00702;405,1.01768;400,1.03354;395,1.05734;390,1.09007;385,1.12974;380,1.17415;375,1.22012;370,1.26080;365,1.27443;360,1.25518;355,1.21863;350,1.17778;345,1.14294;340,1.11193;335,1.08611;330,1.06281;325,1.03504;320,1.00542;315,0.977050;310,0.951680;305,0.932350;300,0.921110;295,0.921890;290,0.932150;285,0.935040;280,0.927920;275,0.906690;270,0.866320;265,0.816080;260,0.770790;255,0.743810;250,0.727770;245,0.718800;240,0.713260];


mcor_false=[213.424,1;216.596,1;219.771,1;222.948,1;226.127,1;229.309,1;232.493,1;235.679,1;238.868,1;242.059,1;245.253,1;248.449,1;251.647,0.593900;254.847,0.597730;258.050,0.603310;261.255,0.606340;264.462,0.610040;267.671,0.606690;270.883,0.604010;274.097,0.598840;277.313,0.592740;280.531,0.587260;283.751,0.581240;286.973,0.581390;290.198,0.590660;293.424,0.610140;296.653,0.636860;299.884,0.669330;303.117,0.709510;306.351,0.754030;309.588,0.800950;312.827,0.852120;316.068,0.898760;319.311,0.936010;322.556,0.955090;325.802,0.973610;329.051,0.995920;332.301,1.01291;335.554,1.02158;338.808,1.03281;342.064,1.03632;345.322,1.04815;348.582,1.07323;351.844,1.09826;355.107,1.12431;358.372,1.16529;361.639,1.21036;364.908,1.22113;368.178,1.27726;371.450,1.28974;374.724,1.37042;378,1.36002;381.277,1.42597;384.555,1.37236;387.836,1.32354;391.118,1.20302;394.401,1.17435;397.686,1.11979;400.973,1.07594;404.261,1.04199;407.551,1.02266;410.842,0.994950;414.134,0.976160;417.429,0.949300;420.724,0.926660;424.021,0.906800;427.319,0.897830;430.619,0.883820;433.920,0.879500;437.222,0.875670;440.526,0.872600;443.831,0.864630;447.137,0.854890;450.445,0.850250;453.754,0.843940;457.064,0.846200;460.375,0.841860;463.687,0.834960;467.001,0.829420;470.316,0.824440;473.631,0.822610;476.948,0.827500;480.266,0.823440;483.585,0.827920;486.906,0.839880;490.227,0.846870;493.549,0.841670;496.872,0.852980;500.196,0.814050;503.521,0.800650;506.847,0.797870;510.174,0.789520;513.502,0.790140;516.831,0.791090;520.160,0.806680;523.491,0.805330;526.822,0.798160;530.154,0.788300;533.486,0.786440;536.820,0.796;540.154,0.804870;543.489,0.827730;546.825,0.846370;550.161,0.841960;553.498,0.846660;556.835,0.849950;560.173,0.848300;563.512,0.866490;566.851,0.888020;570.191,0.918660;573.531,0.952280;576.872,0.944290;580.213,0.964790;583.554,0.944430;586.896,0.999890;590.239,1.02528;593.582,1.02276;596.925,1.10148;600.268,1.18985;603.612,1.22043;606.956,1.19824;610.301,1.22396;613.645,1.32472;616.990,1.38332;620.335,1];
xcor_false=[600,0.706630;595,0.710280;590,0.714640;585,0.718150;580,0.720940;575,0.724570;570,0.729130;565,0.733460;560,0.738210;555,0.743860;550,0.750180;545,0.756140;540,0.762070;535,0.768540;530,0.775750;525,0.783020;520,0.790520;515,0.799040;510,0.807940;505,0.817090;500,0.826430;495,0.836310;490,0.846630;485,0.856040;480,0.862870;475,0.873510;470,0.886970;465,0.899560;460,0.911600;455,0.921670;450,0.928170;445,0.932880;440,0.939090;435,0.948890;430,0.962950;425,0.979320;420,0.991910;415,0.998820;410,1.00564;405,1.01806;400,1.03780;395,1.06600;390,1.19;385,1.13795;380,1.17877;375,1.22031;370,1.25516;365,1.26138;360,1.23432;355,1.19158;350,1.14649;345,1.10639;340,1.07012;335,1.03929;330,1.01081;325,0.978880;320,0.946460;315,0.917310;310,0.892480;305,0.873460;300,0.861360;295,0.860480;290,0.869860;285,0.877490;280,0.885440;275,0.885150;270,0.871420;265,0.854100;260,0.836730;255,0.827980;250,0.820980;245,0.814450;240,0.803810];

% Just flipping some data so it can be multiplied properly to create a matrix
xcor_false=flipud(xcor_false);xcor_correct=flipud(xcor_correct);

%% Definition of structures with X- and M-correct matrix
% False correction factor structure:
xmcor_faulty.X=mcor_false(:,2)*(1./xcor_false(:,2)');
xmcor_faulty.Em=mcor_false(:,1);
xmcor_faulty.Ex=xcor_false(:,1);
xmcor_faulty.nEm=size(xmcor_faulty.Em,1);
xmcor_faulty.nEx=size(xmcor_faulty.Ex,1);
% Original correction factor structure:
xmcor_correct.X=mcor_correct(:,2)*(1./xcor_correct(:,2)');
xmcor_correct.Em=mcor_correct(:,1);
xmcor_correct.Ex=xcor_correct(:,1);
xmcor_correct.nEm=size(xmcor_correct.Em,1);
xmcor_correct.nEx=size(xmcor_correct.Ex,1);

if details==true
    f=figure;
    set(f,'InvertHardcopy','off','Color',[1 1 1]);
    ax=axes;
    hold on
    plot(xcor_false(:,1),xcor_false(:,2),'Color','k','LineWidth',1.2,'LineStyle','--')
    plot(mcor_false(:,1),mcor_false(:,2),'Color','r','LineWidth',1.2,'LineStyle','--')
    
    plot(xcor_correct(:,1),xcor_correct(:,2),'Color','k','LineWidth',1.2)
    plot(mcor_correct(:,1),mcor_correct(:,2),'Color','r','LineWidth',1.2)
    legend({'Xcor faulty','Mcor faulty','Xcor correct','Mcor correct'},...
        'NumColumns',2,'location','Northoutside')
    xlabel('Wavelength (nm)')
    ylabel('Correction factor')
        set(ax,'TickDir','out');
    set(ax,'fontsize',10,'FontName','Arial');
    set(ax,'LineWidth',0.5);
    set(ax,'Box','on');
end


%% Interpolation of xmcorrect matrices to increments used in DS
% False xmcorrect
xmcor_faulty.X = interp2(...
    rcvec(xmcor_faulty.Ex,'column'),...
    rcvec(xmcor_faulty.Em,'row'),...
    xmcor_faulty.X,...
    rcvec(datain.Ex,'column'),...
    rcvec(datain.Em,'row')...
    );
xmcor_faulty.X(isnan(xmcor_faulty.X)) = 0 ;
% Original xmcorrect
xmcor_correct.X = interp2(...
    rcvec(xmcor_correct.Ex,'column'),...
    rcvec(xmcor_correct.Em,'row'),...
    xmcor_correct.X,...
    rcvec(datain.Ex,'column'),...
    rcvec(datain.Em,'row')...
    );
xmcor_correct.X(isnan(xmcor_correct.X)) = 0 ;

%% Spectral correction of DS

dataout=datain;

for n=1:dataout.nSample
    eemSample=squeeze(datain.X(n,:,:));    
    eemSample=eemSample./xmcor_faulty.X;
    eemSample=eemSample.*xmcor_correct.X;
    dataout.X(n,:,:)=eemSample;
end

dataout.XMcorrected.applied=true;
dataout.XMcorrected.XMcor_applied=xmcor_correct;
dataout.XMcorrected.XMcor_undone=xmcor_faulty;
dataout.XMcorrected.datetimeapplied=datetime;

end

function [vout] = rcvec(v,rc)
% Make row or column vector
% (C) Urban Wünsch, 2019
% v: vector
% rc: either 'row' ([1:5])or 'column' ([1:5]')
sz=size(v);
if ~any(sz==1)
    error('Input is not a vector')
end

switch rc
    case 'row'
        if ~[sz(1)<sz(2)]
            vout=v';
        else
            vout=v;
        end
    case 'column'
        if ~[sz(1)>sz(2)]
            vout=v';
        else
            vout=v;
        end
    otherwise
            error('Input ''rc'' not recognized. Options are: ''row'' and ''column''.')
end


end

