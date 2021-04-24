a = 1;
Ls = 1;
m = 1;
g = 9.81;

Ts = 0.001;
npts = 1000; % tfinal = 1s
tfinal = Ts*npts;

t = (0:Ts:tfinal-Ts)';

u1 = [t, ones(npts,1)]; 
sim_u1 = sim('sim_levitador',tfinal,[],u1);
yout_u1 = sim_u1.yout;
tout_u1 = sim_u1.tout;
