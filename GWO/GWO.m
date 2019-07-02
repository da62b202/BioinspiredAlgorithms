%___________________________________________________________________%
%  Grey Wold Optimizer (GWO) source codes version 1.0               %
%                                                                   %
%  Developed in MATLAB R2011b(7.13)                                 %
%                                                                   %
%  Author and programmer: Seyedali Mirjalili                        %
%                                                                   %
%         e-Mail: ali.mirjalili@gmail.com                           %
%                 seyedali.mirjalili@griffithuni.edu.au             %
%                                                                   %
%       Homepage: http://www.alimirjalili.com                       %
%                                                                   %
%   Main paper: S. Mirjalili, S. M. Mirjalili, A. Lewis             %
%               Grey Wolf Optimizer, Advances in Engineering        %
%               Software , in press,                                %
%               DOI: 10.1016/j.advengsoft.2013.12.007               %
%                                                                   %
%___________________________________________________________________%

% Grey Wolf Optimizer
function [Alpha_pos, Alpha_score, numGeracoes, melhores_avaliacoes] =GWO(im1, dim, Max_iter, q, parametros)
numGeracoes = Max_iter;
melhores_avaliacoes = zeros(Max_iter,1);
functionName = 'F0';
[fobj] = Get_Functions_detailsGWO(functionName);
H = psrGrayHistogram(im1);
SearchAgents_no = parametros.nLobos;
ub = parametros.UB;
lb = parametros.LB;
range = [2 253];

% initialize alpha, beta, and delta_pos
Alpha_pos=zeros(1,dim);
Alpha_score=-inf; %change this to -inf for maximization problems

Beta_pos=zeros(1,dim);
Beta_score=-inf; %change this to -inf for maximization problems

Delta_pos=zeros(1,dim);
Delta_score=-inf; %change this to -inf for maximization problems

%Initialize the positions of search agents
Positions=initializationGWO(SearchAgents_no,dim,ub,lb);

Positions = sort(Positions')';

l=0;% Loop counter
% Main loop
while l<Max_iter
    Positions = sort(Positions')';
    for k=1:size(Positions,1)  
       % Return back the search agents that go beyond the boundaries of the search space
        Flag4ub=Positions(k,:)>ub;
        Flag4lb=Positions(k,:)<lb;
        
        Positions(k,:)=Positions(k,:).*(~(Flag4ub+Flag4lb))+ub.*Flag4ub+lb.*Flag4lb;     
        
        % Calculate objective function for each search agent
        fitness=fobj(Positions(k, :),H, q);
        % Update Alpha, Beta, and Delta
        if fitness>Alpha_score 
            Alpha_score=fitness; % Update alpha
            Alpha_pos=sort(Positions(k,:));
        end
        
        if fitness<Alpha_score && fitness>Beta_score 
            Beta_score=fitness; % Update beta
            Beta_pos=Positions(k,:);
        end
        
        if fitness<Alpha_score && fitness<Beta_score && fitness>Delta_score 
            Delta_score=fitness; % Update delta
            Delta_pos=Positions(k,:);
        end
    end

    a=2-l*((2)/Max_iter); % a decreases linearly fron 2 to 0
    
    % Update the Position of search agents including omegas
    for i=1:size(Positions,1)
        for j=1:size(Positions,2)     
                    
            r1=rand(); % r1 is a random number in [0,1]
            r2=rand(); % r2 is a random number in [0,1]
            
            A1=2*a*r1-a; % Equation (3.3)
            C1=2*r2; % Equation (3.4)
            
            D_alpha=abs(C1*Alpha_pos(j)-Positions(i,j)); % Equation (3.5)-part 1
            X1=Alpha_pos(j)-A1*D_alpha; % Equation (3.6)-part 1
                       
            r1=rand();
            r2=rand();
            
            A2=2*a*r1-a; % Equation (3.3)
            C2=2*r2; % Equation (3.4)
            
            D_beta=abs(C2*Beta_pos(j)-Positions(i,j)); % Equation (3.5)-part 2
            X2=Beta_pos(j)-A2*D_beta; % Equation (3.6)-part 2       
            
            r1=rand();
            r2=rand(); 
            
            A3=2*a*r1-a; % Equation (3.3)
            C3=2*r2; % Equation (3.4)
            
            D_delta=abs(C3*Delta_pos(j)-Positions(i,j)); % Equation (3.5)-part 3
            X3=Delta_pos(j)-A3*D_delta; % Equation (3.5)-part 3             
            
            Positions(i,j)=(X1+X2+X3)/3;% Equation (3.7)
        end
    end
    melhores_avaliacoes(l+1, 1) = Alpha_score;
    
    if l > 30  && std(melhores_avaliacoes(l-30:l))  < 0.01
       numGeracoes = l;
       break;
    end
    l=l+1;    
end



