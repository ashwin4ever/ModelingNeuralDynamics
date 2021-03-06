clear; clf; rng('default'); rng(63806);
tic;

% Define network parameters: 

num_e=2; num_i=1;
i_ext_e=zeros(2,1); i_ext_e(1)=0.4; i_ext_e(2)=0.8; 
i_ext_i=zeros(1,1);
g_ee=zeros(num_e,num_e); g_ei=zeros(num_e,num_i);
g_ie=zeros(num_i,num_e); g_ii=zeros(num_i,num_i);

g_ei(:,1)=0.125*ones(2,1);
g_ie(1,:)=0.25*ones(1,2);
g_ii(1,1)=0.25;

v_rev_e=0; v_rev_i=-75; 
tau_r_e=0.5; tau_peak_e=0.5; tau_d_e=3; 
tau_r_i=0.5; tau_peak_i=0.5; tau_d_i=9; 
tau_dq_e=tau_d_q_function(tau_d_e,tau_r_e,tau_peak_e);
tau_dq_i=tau_d_q_function(tau_d_i,tau_r_i,tau_peak_i);

t_final=500;    % Time (in ms) simulated. 
dt=0.01;        % Time step used in solving the differential equations.
dt05=dt/2; 
m_steps=round(t_final/dt);

g_ee_vec=[0:50]/50*0.4;
for ijk=1:length(g_ee_vec),
    g_ee(1,2)=0; g_ee(2,1)=g_ee_vec(ijk);
    
    % initialize dynamic variables

    v_e=-70*ones(num_e,1); m_e=m_e_inf(v_e); h_e=h_e_inf(v_e); n_e=n_e_inf(v_e); 
    z=zeros(num_e,1); q_e=z; s_e=z;

    v_i=-75*ones(num_i,1); m_i=m_i_inf(v_i); h_i=h_i_inf(v_i); n_i=n_i_inf(v_i); 
    z=zeros(num_i,1); q_i=z; s_i=z; 

    % solve the system of Hodgkin-Huxley-like equations using the midpoint method

    num_spikes_e=0; t_e_spikes=[]; i_e_spikes=[];
    num_spikes_i=0; t_i_spikes=[]; i_i_spikes=[];

    for k=1:m_steps,
        t_old=(k-1)*dt; t_new=k*dt; t_mid=(t_old+t_new)/2;

        v_e_inc=0.1*(-67-v_e)+80*n_e.^4.*(-100-v_e)+100*m_e.^3.*h_e.*(50-v_e) ...
                   +(g_ee'*s_e).*(v_rev_e-v_e)+(g_ie'*s_i).*(v_rev_i-v_e) ...
                   +i_ext_e;
        n_e_inc=(n_e_inf(v_e)-n_e)./tau_n_e(v_e);
        h_e_inc=(h_e_inf(v_e)-h_e)./tau_h_e(v_e);
        q_e_inc=(1+tanh(v_e/10))/2.*(1-q_e)/0.1-q_e./tau_dq_e;
        s_e_inc=q_e.*(1-s_e)./tau_r_e-s_e./tau_d_e; 
        v_i_inc=0.1*(-65-v_i)+9*n_i.^4.*(-90-v_i)+35*m_i.^3.*h_i.*(55-v_i) ...
                   +(g_ei'*s_e).*(v_rev_e-v_i)+(g_ii'*s_i).*(v_rev_i-v_i) ...
                   +i_ext_i;
        n_i_inc=(n_i_inf(v_i)-n_i)./tau_n_i(v_i);
        h_i_inc=(h_i_inf(v_i)-h_i)./tau_h_i(v_i);
        q_i_inc=(1+tanh(v_i/10))/2.*(1-q_i)/0.1-q_i./tau_dq_i;
        s_i_inc=q_i.*(1-s_i)./tau_r_i-s_i./tau_d_i;

        v_e_tmp=v_e+dt05*v_e_inc;
        n_e_tmp=n_e+dt05*n_e_inc;
        m_e_tmp=m_e_inf(v_e_tmp);
        h_e_tmp=h_e+dt05*h_e_inc;
        q_e_tmp=q_e+dt05*q_e_inc;   
        s_e_tmp=s_e+dt05*s_e_inc; 
        v_i_tmp=v_i+dt05*v_i_inc;
        n_i_tmp=n_i+dt05*n_i_inc;
        m_i_tmp=m_i_inf(v_i_tmp);
        h_i_tmp=h_i+dt05*h_i_inc;
        q_i_tmp=q_i+dt05*q_i_inc;   
        s_i_tmp=s_i+dt05*s_i_inc;    

        v_e_inc=0.1*(-67-v_e_tmp)+80*n_e_tmp.^4.*(-100-v_e_tmp)+100*m_e_tmp.^3.*h_e_tmp.*(50-v_e_tmp) ...
                   +(g_ee'*s_e_tmp).*(v_rev_e-v_e_tmp)+(g_ie'*s_i_tmp).*(v_rev_i-v_e_tmp) ...
                   +i_ext_e;
        n_e_inc=(n_e_inf(v_e_tmp)-n_e_tmp)./tau_n_e(v_e_tmp);
        h_e_inc=(h_e_inf(v_e_tmp)-h_e_tmp)./tau_h_e(v_e_tmp);
        q_e_inc=(1+tanh(v_e_tmp/10))/2.*(1-q_e_tmp)/0.1-q_e_tmp./tau_dq_e;
        s_e_inc=q_e_tmp.*(1-s_e_tmp)./tau_r_e-s_e_tmp./tau_d_e;
        v_i_inc=0.1*(-65-v_i_tmp)+9*n_i_tmp.^4.*(-90-v_i_tmp)+35*m_i_tmp.^3.*h_i_tmp.*(55-v_i_tmp) ...
                   +(g_ei'*s_e_tmp).*(v_rev_e-v_i_tmp)+(g_ii'*s_i_tmp).*(v_rev_i-v_i_tmp) ...
                   +i_ext_i;
        n_i_inc=(n_i_inf(v_i_tmp)-n_i_tmp)./tau_n_i(v_i_tmp);
        h_i_inc=(h_i_inf(v_i_tmp)-h_i_tmp)./tau_h_i(v_i_tmp);
        q_i_inc=(1+tanh(v_i_tmp/10))/2.*(1-q_i_tmp)/0.1-q_i_tmp./tau_dq_i;
        s_i_inc=q_i_tmp.*(1-s_i_tmp)./tau_r_i-s_i_tmp./tau_d_i;

        v_e_old=v_e;
        v_i_old=v_i;

        v_e=v_e+dt*v_e_inc;
        m_e=m_e_inf(v_e); h_e=h_e+dt*h_e_inc; n_e=n_e+dt*n_e_inc; 
        q_e=q_e+dt*q_e_inc;
        s_e=s_e+dt*s_e_inc;
        v_i=v_i+dt*v_i_inc;
        m_i=m_i_inf(v_i); h_i=h_i+dt*h_i_inc; n_i=n_i+dt*n_i_inc; 
        q_i=q_i+dt*q_i_inc;
        s_i=s_i+dt*s_i_inc;


        % Determine which and how many e- and i-cells spiked in the current 
        % time step:

        which_e=find(v_e_old<-40 & v_e >=-40); which_i=find(v_i_old<-40 & v_i >=-40);
        l_e=length(which_e); l_i=length(which_i);
        if l_e>0, 
            range=num_spikes_e+1:num_spikes_e+l_e; i_e_spikes(range)=which_e; 
            t_e_spikes(range)= ...
                ((v_e(which_e)+40)*(k-1)*dt+(-v_e_old(which_e)-40)*k*dt)./ ...
                    (v_e(which_e)-v_e_old(which_e));
            num_spikes_e=num_spikes_e+l_e;
        end 
        if l_i>0, 
            range=num_spikes_i+1:num_spikes_i+l_i; i_i_spikes(range)=which_i; 
            t_i_spikes(range)= ...
                ((40+v_i(which_i))*(k-1)*dt+(-v_i_old(which_i)-40)*k*dt)./ ...
                    (v_i(which_i)-v_i_old(which_i));
            num_spikes_i=num_spikes_i+l_i;
        end 

    end;

    ind1=find(i_e_spikes==1 & t_e_spikes>t_final/2);
    ind2=find(i_e_spikes==2 & t_e_spikes>t_final/2);
    t_e_spikes_1=t_e_spikes(ind1); num_spikes_e_1=length(ind1);
    t_e_spikes_2=t_e_spikes(ind2); num_spikes_e_2=length(ind2);
    delta=0;
    length_delta=0;
    for j=1:num_spikes_e_2,
        ind=find(t_e_spikes_1>t_e_spikes_2(j));
        if length(ind)>0,
            delta=delta+min(t_e_spikes_1(ind))-t_e_spikes_2(j);
            length_delta=length_delta+1;
        end;
    end
    delta=delta/length_delta
    delta_vec(ijk)=delta;
    f_vec(ijk)=mean(t_e_spikes_2(2:num_spikes_e_2)- ...
                    t_e_spikes_2(1:num_spikes_e_2-1));
    f_vec(ijk)=1000/f_vec(ijk);
                
end;

subplot(221);
plot(g_ee_vec,delta_vec,'-k','Linewidth',2);
set(gca,'Fontsize',16);
xlabel('$\overline{g}_{EE}$','Fontsize',20);
ylabel('$\delta$','Fontsize',20);
axis([0,max(g_ee_vec),0,30]);

subplot(222);
plot(g_ee_vec,f_vec,'-k','Linewidth',2);
set(gca,'Fontsize',16);
xlabel('$\overline{g}_{EE}$','Fontsize',20);
ylabel('$f$','Fontsize',20);
axis([0,max(g_ee_vec),0,200]);
shg;


    

toc

