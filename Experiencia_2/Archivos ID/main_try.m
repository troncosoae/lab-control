Ts = 0.002;           
tfinal = 4;
t = (0:Ts:tfinal)';
npts = length(t);

prbs = @(N) randi([0 1], 1, N);

u1 = [t, transpose(prbs(npts))];

%% plot

[t1,x,y1] = sim('BlackBox',tfinal,[],u1); 
figure
grid on
plot(t1,y1)
title('Respuesta a u1')
xlabel('t')
ylabel('Magnitud')

%% make lengths equal

u = u1(:,2);
y = y1;

zeros_to_add = length(y)-length(u);
u = [u; zeros(zeros_to_add,1)];

%% get corrs

gamma = length(u);

R_u = circ_corr(u,u,gamma);

R_y = circ_corr(y,y,gamma);

R_uy = circ_corr(u,y,gamma);

%% get window

length_hann = length(R_u);
W = hann(length_hann);

%% get estimated spectrums

Phi_u = spectrum(R_u.*W);
Phi_uy = spectrum(R_uy.*W);

%% get G

G = Phi_uy./Phi_u;

%% plot spectrum mag
figure
semilogy(-pi:2*pi/(length(G)-1):pi,abs(G))

%% plot spectrum phase
figure
plot(-pi:2*pi/(length(G)-1):pi,angle(G))