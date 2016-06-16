function [Xp, Yp, Zp, Bp] = RaceModel(X,Y,Z,P,Plot)
%--------------------------------------------------------------------------
% REFERENCE
%--------------------------------------------------------------------------
% From Ulrich, R., Miller, J., & Schroter, H. (2007). Testing the race
% model inequality: An algorithm and computer programs. Behavior Research
% Methods, 39(2), 291-302. 

% Annotations in preamble on how to use added by me are denoted by BR-I.
% Otherwise as reported in the paper. 

%% RACE MODEL 

% This appendix presents a MATLAB version of the algorithm described in the text, including handling of ties as
% described in Appendix A. This MATLAB program performs Steps 1, 2, and 3 of the algorithm, and it is written
% as a function that can be integrated into any larger program or simply called at the command window to analyze
% the data set of a single participant. The function requires as input (1) the vectors X, Y, and Z of RTs in conditions
% Cx, Cy, and Cz, respectively; (2) a vector, P, of percentile points at which to test the inequality; and (3) a boolean
% variable, Plot, indicating whether a plot should be produced (i.e., Plot  true) or not (Plot  false). It returns
% the desired percentile values Xp, Yp, and Zp for conditions Cx, Cy, and Cz, respectively, and the percentiles Bp
% for the bound B, as well as a plot of the key values if one is requested.

% X,Y,Z are arrays with RTs for conditions Cx, Cy, Cz, respectively.
% (BR-I: RTs need to be fed in as rows, not columns). 
% P is an array which contains the probabilities for computing percentiles.
% (BR-I: P needs to be decimal i.e. 0.0 - 1.0, again as a row).
% If Plot==true, a plot of the result is generated.

%%% Step 1: Determine Gx, Gy, and Gz %%%

%Check for ties
 [Ux, Rx, Cx]=ties(X);
 [Uy, Ry, Cy]=ties(Y);
 [Uz, Rz, Cz]=ties(Z);
 
%Get maximum t value
 tmax=ceil(max([X Y Z]));
 T=1:1:tmax;
 
%Get function values of G
 [Gx]=CDF(Ux,Rx,Cx,tmax);
 [Gy]=CDF(Uy,Ry,Cy,tmax);
 [Gz]=CDF(Uz,Rz,Cz,tmax);
 
%%% Step 2: Compute B = Gx plus Gy %%%

for t=1:tmax;
 B(t)=Gx(t)+Gy(t);
end

%Check whether requested percentiles can be computed
OKx = check(Ux(1),P(1),Gx);

if OKx == false
 disp('Not enough X values to compute requested percentiles')
 Xp=NaN;Yp=NaN;Zp=NaN;Bp=NaN;
 return
end

OKy = check(Uy(1),P(1),Gy);

if OKy == false
 disp('Not enough Y values to compute requested percentiles')
 Xp=NaN;Yp=NaN;Zp=NaN;Bp=NaN;
 return
end

OKz = check(Uz(1),P(1),Gz);

if OKz == false
 disp('Not enough Z values to compute requested percentiles')
 Xp=NaN;Yp=NaN;Zp=NaN;Bp=NaN;
 return
end

%%% Step 3: Determine percentiles %%%

[Xp] = GetPercentile(P,Gx,tmax);
[Yp] = GetPercentile(P,Gy,tmax);
[Zp] = GetPercentile(P,Gz,tmax);
[Bp] = GetPercentile(P,B,tmax);

%Generate a plot if requested
if Plot == true
 plot(Xp,P,'o-',Yp,P,'o-',Zp,P,'o-',Bp,P,'o-')
 axis([min([Ux Uy Uz])-10 tmax+10 -0.03 1.03])
 grid on
 title('Test of the Race Model Inequality','FontSize',16)
 xlabel('Time t (ms)','FontSize',14)
 ylabel('Probability','FontSize',14)
 legend('G_x(t)','G_y(t)','G_z(t)','G_x(t)+G_y(t)',4)
end

% return to calling routine.
function OK=check(U1,P1,G)
 OK=true;
 for t=(U1-2):(U1+2);
 if (G(t)>P1) && (G(t-1)==0)
 OK=false;
 return
 end
 end
 %END of check
 
function [Tp] = GetPercentile(P,G,tmax)
%Determine minimum of |G(Tp(i))-P(i)|
np=length(P);
for i=1:np;
cc=100;
 for t=1:tmax
 if abs(G(t)-P(i)) < cc
 c=t;
 cc=abs(G(t)-P(i));
 end
 end
 if P(i) > G(c)
 Tp(i)=c+(P(i)-G(c))/(G(c+1)-G(c));
 else
 Tp(i)=c+(P(i)-G(c))/(G(c)-G(c-1));
 end
end
% End of GetPercentile

function [U, R, C]=ties(W)
% Count number k of unique values
% and store these values in U.
 W=sort(W);
 n=length(W);
 k=1;
 U(1)=W(1);
 for i=2:n
 if W(i)~=W(i-1)
 k=k+1;
 U(k)=W(i);
 end
 end
% Determine number of replications R
 R=zeros(1,k);
 for i=1:k
 for j=1:n
 if U(i)==W(j)
 R(i)=R(i)+1;
 end
 end
 end
 % Determine the cumulative frequency 
 C = zeros(1,k); 
 C(1) = R(1); 
 for i = 2:k
     C(i)=C(i-1)+R(i); 
 end 
%END of Ties 
 
function [G]=CDF(U,R,C,maximum)
G=zeros(1,maximum);
k=length(U); n=C(k);
for i=1:k;
 U(i)=round(U(i));
end
for t=1:U(1);
 G(t)=0;
end;
for t=U(1):U(2);
 G(t)=(R(1)/2+(R(1)+R(2))/2*(t-U(1))/(U(2)-U(1)))/n;
end;
for i=2:(k-1);
 for t=U(i):U(i+1);
 G(t)=(C(i-1)+R(i)/2+(R(i)+R(i+1))/2*(t-U(i))/(U(i+1)-U(i)))/n;
 end
end
for t=U(k):maximum;
 G(t)=1;
end;
% End of RaceModel