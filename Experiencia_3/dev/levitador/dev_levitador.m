a = 0.04939; % encontrado para a partir de valores dados
Ls = 0.014;
m = 0.025;
g = 9.81;

x2_eq = 0.05; % 5cm
u_eq = sqrt(exp(x2_eq/a)*g*2*m*a/Ls);
display(u_eq)

a12 = -Ls/(2*a*m)*u_eq^2*-1/a*exp(-x2_eq/a);
b1 = -Ls/(2*a*m)*exp(-x2_eq/a)*2*u_eq;

A = [0 a12; 1 0];
B = [b1; 0];
C = [1 0];
D = 0;

sys = ss(A,B,C,D);

%%

K = tf([1 20 100],[1 0]);
Kx = tf([20],[1]);

G_prima = K*sys/(1 + K*sys);

