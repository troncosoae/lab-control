syms s

a = 1;
% b = 2;
% c = 1;
K = 1;
a = 1-K;

[N1, D1] = numden((K/s)*( s/(s*(s-a) + K)))


cn = coeffs(N1, 'All'); % numerador planta
cd = coeffs(D1, 'All'); % denominador planta


cnn = zeros(1,length(cn));
for i=1:length(cn)
    cnn(i) = cn(i);
end
cdd = zeros(1,length(cd));
for i=1:length(cd)
    cdd(i) = cd(i);
end
sys_planta = tf(cnn,cdd, 1);


polos = roots(cdd)
ceros = roots(cnn)

% rlocus(sys_planta)
% pause

% ----- tuneo controlador -----
tipo = 'PID'; % PI, PD, PID
% tuneo del controlador:
% pidTuner(sys_planta,tipo)
Kp = 0.5; % 115.2; % 8.71;
Ki = 3; % 177.2; % 46.9;
Kd = 1; % 18.72; %0.04;
control = ((Kd/Kp)*s + Ki/(Kp*s) + 1)*Kp;
[N,D] = numden(control);

% ----- si no se tunea, dejar constantes en 0 -----
% sensor = (-s+1)/(s+a);
% [Ns,Ds] = numden(sensor);

cn_c = coeffs(N, 'All'); % numerador controlador
cd_c = coeffs(D, 'All'); % denominador controlador


% cn_s = coeffs(Ns, 'All'); % numerador sensor
% cd_s = coeffs(Ds, 'All'); % denominador sensor


cnn_c = zeros(1,length(cn_c));
for i=1:length(cn_c)
    cnn_c(i) = cn_c(i);
end
cdd_c = zeros(1,length(cd_c));
for i=1:length(cd_c)
    cdd_c(i) = cd_c(i);
end

% cnn_s = zeros(1,length(cn_s));
% for i=1:length(cn_s)
%     cnn_s(i) = cn_s(i);
% end
% cdd_s = zeros(1,length(cd_s));
% for i=1:length(cd_s)
%     cdd_s(i) = cd_s(i);
% end

sys_controlador = tf(cnn_c,cdd_c,1);
% sys_sensor = tf(cnn_s,cdd_s,1);
% funcion_transf = (sys_planta*sys_controlador)/(1+sys_planta*sys_controlador*1)
funcion_transf = sys_planta


%% HERRAMIENTAS DE ANÁLISIS

% rlocus(funcion_transf)
% step(funcion_transf)
controlSystemDesigner(funcion_transf) 