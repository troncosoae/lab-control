clear all
close all
clc;

tic
echo on 
% Parametros para la identifiación:
echo off

tau = 0.05; % periodo de u
Ts = 0.0005;
tau_indice = round(tau/Ts);
tfinal = 2;
Cs = 0.3; % controlador malo que se debe poner antes de LS
t = (Ts:Ts:tfinal)';
b = (1/tau_indice)*ones(1,tau_indice);
a = 1;
npts = length(t);

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

% prbs = @(N) randi([0 1], 1, N);
% periodo_PRBS = filter(b, a, prbs(tau_indice));
% entrada_PRBS = repmat(periodo_PRBS, 1, round(npts/tau_indice));

divisiones_periodos = 10;

NumChannel = 1;
Period = npts/divisiones_periodos;
NumPeriod = round(npts/Period);
entrada_PRBS = idinput([Period,NumChannel,NumPeriod]);
sim_PRBS = [t, entrada_PRBS, zeros(npts,1)];

tamano_ventana = Period;

[t_PRBS,x,y_PRBS] = sim('loopshape',tfinal,[],sim_PRBS);
y_PRBS = y_PRBS(1:round(length(y_PRBS)/divisiones_periodos)*round(divisiones_periodos));
y_aux = reshape(y_PRBS,divisiones_periodos,[]);
y_PRBS = mean(y_aux);
c = entrada_PRBS(1:length(y_PRBS));

[x3 ~] = size(y_PRBS);
[x1 ~] = size(entrada_PRBS);

% c = [entrada_PRBS; zeros(x3-x1,1)];

%Calcular la función de transferencia correspondiente

% Paso 1: Realizar estimadores de funciones de intercorrelación Ryy, Ryu, Ruu
N = length(y_PRBS);
% Ryy = 1/N * xcorr(y_PRBS(:,1), circshift(y_PRBS(:,1), round(tau_indice/2)));
% Ryu = 1/N * xcorr(y_PRBS(:,1), circshift(c, round(tau_indice/2)));
% Ruu = 1/N * xcorr(c, circshift(c, round(tau_indice/2)));
Ryy = 1/N * cconv(y_PRBS(:,1),conj(fliplr(y_PRBS(:,1))), N);
Ryu = 1/N * cconv(y_PRBS(:,1),conj(fliplr(c)), N);
Ruu = 1/N * cconv(c,conj(fliplr(c)),N);

lados_ventana = round((length(Ryy) - tamano_ventana)/2);

w = hanning(tamano_ventana); % Ventana de Hanning
w = [zeros(lados_ventana, 1) ; w ; zeros(lados_ventana, 1)];

% Paso 2: Realizar estimadores de los espectros
% w = [zeros(ry_s,1); w; zeros(ry_s,1)];
Oyy = fft(Ryy.*w);
Oyu = fft(Ryu.*w);
Ouu = fft(Ruu.*w);

% Paso 3: Finalmente se encuentra la función de transferencia estimada

Gw_u1 = Oyu/Ouu;
disturbance_u1 = Oyy - abs(Oyu).^2/Ouu;
coherence_u1 = sqrt(abs(Oyu).^2/(Oyy'*Ouu));

figure
semilogx(mag2db(abs(Gw_u1)));
title('Diagrama de Bode xcorr u1 - Magnitud')
grid on
xlabel('Frecuencia en Hz')
ylabel('Magnitud en dB')

figure
semilogx(57.29*angle(Gw_u1));
title('Diagrama de Bode xcorr u1 - Fase')
grid on
xlabel('Frecuencia en Hz')
ylabel('Fase en grados')

% figure
% semilogx(mag2db(abs(disturbance_u1)));
% title('Espectro de perturbaci�n u1')
% grid on
% xlabel('Frecuencia en Hz')
% ylabel('Magnitud en dB')

% figure
% semilogx(mag2db(abs(coherence_u1)));
% title('Espectro de coherencia u1')
% grid on
% xlabel('Frecuencia en Hz')
% ylabel('Magnitud en dB')


% Ryy = 1/N * xcorr(y_PRBS(:,2), circshift(y_PRBS(:,2), round(tau_indice/2)));
% Ryu = 1/N * xcorr(y_PRBS(:,2), circshift(c, round(tau_indice/2)));
% Ruu = 1/N * xcorr(c, circshift(c, round(tau_indice/2)));

Ryy = 1/N * cconv(y_PRBS(:,2),conj(fliplr(y_PRBS(:,2))), 2*length(y_PRBS));
Ryu = 1/N * cconv(y_PRBS(:,2),conj(fliplr(c)), 2*length(y_PRBS));
Ruu = 1/N * cconv(c,conj(fliplr(c)),2*length(y_PRBS));

[ry_s ~] = size(Ryy);

lados_ventana = round((length(Ryy) - tamano_ventana)/2);

w = hanning(tamano_ventana); % Ventana de Hanning
w = [zeros(lados_ventana, 1) ; w ; zeros(lados_ventana, 1)];

% Paso 2: Realizar estimadores de los espectros
% w = [zeros(ry_s,1); w; zeros(ry_s,1)];
Oyy = fft(Ryy.*w);
Oyu = fft(Ryu.*w);
Ouu = fft(Ruu.*w);

% Paso 3: Finalmente se encuentra la función de transferencia estimada

Gw_u2 = Oyu/Ouu;
disturbance_u2 = Oyy - abs(Oyu).^2/Ouu;
coherence_u2 = sqrt(abs(Oyu).^2/(Oyy'*Ouu));

figure
semilogx(mag2db(abs(Gw_u2)));
title('Diagrama de Bode xcorr u2 - Magnitud')
grid on
xlabel('Frecuencia en Hz')
ylabel('Magnitud en dB')

figure
semilogx(57.29*angle(Gw_u2));
title('Diagrama de Bode xcorr u2 - Fase')
grid on
xlabel('Frecuencia en Hz')
ylabel('Fase en grados')

% figure
% semilogx(mag2db(abs(disturbance_u2)));
% title('Espectro de perturbaci�n u2')
% grid on
% xlabel('Frecuencia en Hz')
% ylabel('Magnitud en dB')

% figure
% semilogx(mag2db(abs(coherence_u2)));
% title('Espectro de coherencia u2')
% grid on
% xlabel('Frecuencia en Hz')
% ylabel('Magnitud en dB')

disp('Push any key to begin the identification routine'); pause


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
title('Respuesta a PRBS u1')
grid on
xlabel('t')
ylabel('Magnitud')
figure
grid on
plot(t_PRBS,y_PRBS(:,2))
title('Respuesta a PRBS u2')
grid on
xlabel('t')
ylabel('Magnitud')

disp('Push any key to begin the identification routine'); pause

z = [y_PRBS c];
[G FIV] = spa(z);

np = 3; % numero de polos
nz = 3; % numero de ceros
sys = tfest(z,np,nz); % estimacion de funcion de transferencia

opts = bodeoptions('cstprefs');
opts.Title.String = 'Estimated frequency response (spa)';
opts.Title.FontSize = 12;

figure
h = bodeplot(G, opts);
showConfidence(h,3)

opts = bodeoptions('cstprefs');
opts.Title.String = 'Estimated transfer function (tfest)';
opts.Title.FontSize = 12;

figure
h = bodeplot(sys, opts);
showConfidence(h,3)

figure
spect = spectrumplot(G);
showConfidence(spect,3)

[Cxy,F] = mscohere(y_PRBS, c, W_Hanning);
figure 
plot(F,Cxy); title('Magnitude-Squared Coherence'); xlabel('Frequency (Hz)'); grid on


% disp('Push any key to begin the plotting section'); pause
% disp('paused: push any key to continue'); pause
% figure
% grid on
% plot(t_PRBS,y_PRBS_FILTERED(:,1))
% title('Respuesta a PRBS - versi�n filtrada con media m�vil de ventana tau')
% grid on
% xlabel('t')
% ylabel('Magnitud')