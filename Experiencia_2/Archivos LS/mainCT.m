clear all
close all
clc;

tic
echo on 
% Parametros para la identifiación:
echo off

tau = 0.05; % periodo de u
Ts = 0.005
tau_indice = round(tau/Ts);
tfinal = 2
Cs = 0.3; % controlador malo que se debe poner antes de LS
t = (Ts:Ts:tfinal)';
b = (1/tau_indice)*ones(1,tau_indice);
a = 1;
npts = length(t)

echo on
% El modelo Simulink será simulado a continuación. Primero se construye la
% entrada del sistema y luego se usa la función sim para simular y capturar
% los valores de la salida.
echo off

% u1 = [t, 2*ones(npts,1), zeros(npts,1)];     
% u2 = [t, -2*ones(npts,1), zeros(npts,1)];         
% [t1,x,y1] = sim('loopshape_id',tfinal,[],u1);        
% [t2,x,y2] = sim('loopshape_id',tfinal,[],u2);
toc
echo on
% Se presentan gráficos de las respuestas
echo off

prbs = @(N) randi([0 1], 1, N);
periodo_PRBS = filter(b, a, prbs(tau_indice));
entrada_PRBS = repmat(periodo_PRBS, 1, round(npts/tau_indice));
sim_PRBS = [t, entrada_PRBS', zeros(npts,1)];

[t_PRBS,x,y_PRBS] = sim('loopshape_id',tfinal,[],sim_PRBS); 

y_PRBS_FILTERED = filter(b,a,y_PRBS);
W_hamming = hamming(tau_indice);

TF_muestras = zeros(length(0 : (2*pi)*Ts : 2*pi), 1);
frecuencias = 0 : (2*pi)/npts : 2*pi;

indice = 1;
for w = 0 : (2*pi)/npts : 2*pi
    TF_muestras(indice) = Gw_estimate(w, tau_indice, entrada_PRBS, y_PRBS, npts, Ts, W_hamming);
    indice = indice + 1;
end

resultados = [frecuencias/Ts ; TF_muestras']

figure
grid on
plot(0.159*frecuencias/Ts, mag2db(abs(TF_muestras')))
title('Diagrama G(w) - Magnitud')
grid on
xlabel('Frecuencia en Hz')
ylabel('Magnitud en dB')

figure
grid on
plot(0.159*frecuencias/Ts, 57.29*imag(TF_muestras'))
title('Diagrama G(w) - Fase')
grid on
xlabel('Frecuencia en Hz')
ylabel('Fase en grados sexagesimales')

% disp('Push any key to begin the plotting section'); pause
figure
grid on
plot(entrada_PRBS)
title('Entrada PRBS filtrada')
grid on
xlabel('t')
ylabel('Magnitud')
figure
grid on
plot(t_PRBS,y_PRBS(:,1))
title('Respuesta a PRBS')
grid on
xlabel('t')
ylabel('Magnitud')
% disp('paused: push any key to continue'); pause
figure
grid on
plot(t_PRBS,y_PRBS_FILTERED(:,1))
title('Respuesta a PRBS - versi�n filtrada con media m�vil de ventana tau')
grid on
xlabel('t')
ylabel('Magnitud')