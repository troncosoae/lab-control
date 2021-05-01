R_l = 35;
K_h = 1.58;
T_h = 0.47;
R_ag = 0.4;
L_ag = 140* 10^(-6);
K_g = 0.0032;
R_am = 0.14;
L_am = 50 * 10^(-6);
K_m = 0.000433;
R_as = 10;
L_as = 22*10^(-6);
K_s = 0.003;
B = 2*10^(-6);
J = 2.1 * 10^(-6);
v_A0 = 2;
omega_0 = 1500;

R_f = 10000;
C_f = 1000*10^(-9);

% variable s es simbólica para que matlab haga álgebra por uno
syms s

num = [143134928095778949120000, 36192688961361248563200000000];
den = [34709393649091889, 8873737467196072166715, 24583972753858281030182000, 42460474904292344280000000];

K_p = 0.22;
K_i = 0.26;
K_d = 0.18;
N = 186;
pid = simplify(K_p + K_i*1/s + K_d*N/(1 + N*(1/s)));
[N, D] = numden(pid);

PID = tf([ 2418 2059 1685], [ 9300 50]);
% PID = tf([1 1], [5 0]);
%PID = tf([K_d, K_p, K_i], [1, 0]);
convertidor = tf([K_h], [T_h, 1]);
sensor = tf([K_s], [R_f*C_f, 1]);

% descomentar TF_motor_generador para ver la simplificación de la función
% de transferencia original
% TF_motor_generador = simplify((K_m/(R_am + L_am*s))/(B + J*s + (K_m^2/(R_am + L_am*s)) + (K_g^2/(R_ag + R_l + L_ag*s))));

TF_mg = tf(num, den);
TF_scontrol = TF_mg*convertidor/(1 + TF_mg*convertidor*sensor);

sistema = PID*TF_mg*convertidor/(1 + PID*TF_mg*convertidor*sensor);

% [A, B, C, D] = tf2ss(num, den);

% rltool(TF_mg)
% rltool(sistema)
% pidTuner(TF_scontrol)

rlocus(TF_mg, 'b', sistema, 'k', TF_scontrol, 'r')
hold on
legend('Motor/Generador','Motor/Generador con controlador PID', 'Motor Actuador sensor sin controlador')
hold off


