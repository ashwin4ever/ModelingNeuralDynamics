clear; clf;
c=1;
g_k=36; 
g_na=120;
g_l=0.3;
v_k=-82;
v_na=45;
v_l=-59;

i_ext=5.5;
f=@(v) g_na*m_inf(v).^3.*(0.83-n_inf(v)).*(v_na-v)+ ...
       g_k*n_inf(v).^4.*(v_k-v)+ ...
       g_l*(v_l-v);
v_left=-100;
v_right=50;
while v_right-v_left>10^(-10),
    v_c=(v_left+v_right)/2;
    if (f(v_c)+i_ext)*(f(v_left)+i_ext)>0,
        v_left=v_c;
    else
        v_right=v_c;
    end;
end;
v_c=(v_left+v_right)/2;
n_c=n_inf(v_c);

t_final=1000;
dt=0.01; dt05=dt/2;
m_steps=round(t_final/dt);

v(1)=20;
n(1)=n_c;
m(1)=m_inf(v(1));
h(1)=0.83-n(1);

for k=1:m_steps,
    
    v_inc=(g_na*m(k)^3*h(k)*(v_na-v(k))+g_k*n(k)^4*(v_k-v(k))+g_l*(v_l-v(k))+i_ext)/c;
    n_inc=alpha_n(v(k))*(1-n(k))-beta_n(v(k))*n(k);
    
    v_tmp=v(k)+dt05*v_inc;
    n_tmp=n(k)+dt05*n_inc;
    m_tmp=m_inf(v_tmp);
    h_tmp=0.83-n_tmp;
    
    v_inc=(g_na*m_tmp^3*h_tmp*(v_na-v_tmp)+g_k*n_tmp^4*(v_k-v_tmp)+g_l*(v_l-v_tmp)+i_ext)/c;
    n_inc=alpha_n(v_tmp)*(1-n_tmp)-beta_n(v_tmp)*n_tmp;
    
    v(k+1)=v(k)+dt*v_inc;
    n(k+1)=n(k)+dt*n_inc;
    m(k+1)=m_inf(v(k+1));
    h(k+1)=0.83-n(k+1);
end;

t=[0:m_steps]*dt;
i=round((t_final-20)/dt);
ind=[i+1:m_steps+1];
t=t(ind);
v=v(ind);
n=n(ind);

subplot(221);
hold on;
plot(v,n,'-k','Linewidth',2);
set(gca,'Fontsize',16);
xlabel('$v$','Fontsize',20);
ylabel('$n$','Fontsize',20);
axis([-100,50,0.3,0.8]);
axis('square');

subplot(222);
hold on;
plot(v,n,'-k','Linewidth',2);
set(gca,'Fontsize',16);
xlabel('$v$','Fontsize',20);
ylabel('$n$','Fontsize',20);
plot(v_c,n_c,'.','Markersize',25);
axis([-75,-55,0.35,0.45])
axis('square');


v(1)=v_c+0.001;
n(1)=n_c;
m(1)=m_inf(v(1));
h(1)=0.83-n(1);

for k=1:m_steps,
    
    v_inc=(g_na*m(k)^3*h(k)*(v_na-v(k))+g_k*n(k)^4*(v_k-v(k))+g_l*(v_l-v(k))+i_ext)/c;
    n_inc=alpha_n(v(k))*(1-n(k))-beta_n(v(k))*n(k);
    
    v_tmp=v(k)-dt05*v_inc;
    n_tmp=n(k)-dt05*n_inc;
    m_tmp=m_inf(v_tmp);
    h_tmp=0.83-n_tmp;
    
    v_inc=(g_na*m_tmp^3*h_tmp*(v_na-v_tmp)+g_k*n_tmp^4*(v_k-v_tmp)+g_l*(v_l-v_tmp)+i_ext)/c;
    n_inc=alpha_n(v_tmp)*(1-n_tmp)-beta_n(v_tmp)*n_tmp;
    
    v(k+1)=v(k)-dt*v_inc;
    n(k+1)=n(k)-dt*n_inc;
    m(k+1)=m_inf(v(k+1));
    h(k+1)=0.83-n(k+1);
end;

t=[0:m_steps]*dt;
i=round((t_final-15)/dt);
ind=[i+1:m_steps+1];
t=t(ind);
v=v(ind);
n=n(ind);

subplot(221);
plot(v,n,':r','Linewidth',2);
hold off;

set(gca,'box','on');

subplot(222);
h=plot(v,n,':r','Linewidth',2);
hold off;

set(gca,'box','on');



shg;
    
    
