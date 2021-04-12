clear all
close all
clc;

tic
echo on 
% Parametros para la identifiaci贸n:
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
% El modelo Simulink ser谩 simulado a continuaci贸n. Primero se construye la
% entrada del sistema y luego se usa la funci贸n sim para simular y capturar
% los valores de la salida.
echo off

% u1 = [t, 2*ones(npts,1), zeros(npts,1)];     
% u2 = [t, -2*ones(npts,1), zeros(npts,1)];         
% [t1,x,y1] = sim('loopshape_id',tfinal,[],u1);        
% [t2,x,y2] = sim('loopshape_id',tfinal,[],u2);
toc
echo on
% Se presentan gr谩ficos de las respuestas
echo off

prbs = @(N) randi([0 1], 1, N);
periodo_PRBS = filter(b, a, prbs(tau_indice));
entrada_PRBS = repmat(periodo_PRBS, 1, round(npts/tau_indice));
sim_PRBS = [t, entrada_PRBS', zeros(npts,1)];

[t_PRBS,x,y_PRBS] = sim('loopshape',tfinal,[],sim_PRBS); 

y_PRBS_FILTERED = filter(b,a,y_PRBS);
W_Hanning = hanning(tau_indice);

TF_muestras_u1 = zeros(length(0 : (2*pi)/npts : 2*pi), 1);
disturbance_spectrum_muestras_u1 = zeros(length(0 : (2*pi)/npts : 2*pi), 1);
coherence_spectrum_muestras_u1 = zeros(length(0 : (2*pi)/npts : 2*pi), 1);
TF_muestras_u2 = zeros(length(0 : (2*pi)/npts : 2*pi), 1);
disturbance_spectrum_muestras_u2 = zeros(length(0 : (2*pi)/npts : 2*pi), 1);
coherence_spectrum_muestras_u2 = zeros(length(0 : (2*pi)/npts : 2*pi), 1);
frecuencias = 0 : (2*pi)/npts : 2*pi;

[x3 ~] = size(y_PRBS);
[x1 ~] = size(entrada_PRBS');

c = [entrada_PRBS'; zeros(x3-x1,1)];

indice = 1;
for w = 0 : (10*pi)/npts : 10*pi
    [TF, dist_spect, coherence_spect] = Gw_estimate(w, tau_indice, c, y_PRBS(:,1), length(y_PRBS), Ts, W_Hanning);
    TF_muestras_u1(indice) = TF;
    disturbance_spectrum_muestras_u1(indice) = dist_spect;
    coherence_spectrum_muestras_u1(indice) = coherence_spect;
    indice = indice + 1;
end
indice = 1;
for w = 0 : (10*pi)/npts : 10*pi
    [TF, dist_spect, coherence_spect] = Gw_estimate(w, tau_indice, c, y_PRBS(:,2), length(y_PRBS), Ts, W_Hanning);
    TF_muestras_u2(indice) = TF;
    disturbance_spectrum_muestras_u2(indice) = dist_spect;
    coherence_spectrum_muestras_u2(indice) = coherence_spect;
    indice = indice + 1;
end

figure
grid on
semilogx(frecuencias(1:round(length(disturbance_spectrum_muestras_u1)/2))/Ts, mag2db(abs(disturbance_spectrum_muestras_u1(1:round(length(disturbance_spectrum_muestras_u1)/2))')))
title('Diagrama Espectro de perturbaci髇 u1')
grid on
xlabel('Frecuencia en rad/s')
ylabel('Magnitud en dB')

figure
grid on
semilogx(frecuencias(1:round(length(disturbance_spectrum_muestras_u1)/2))/Ts, mag2db(abs(coherence_spectrum_muestras_u1(1:round(length(disturbance_spectrum_muestras_u1)/2))')))
title('Diagrama Espectro de coherencia u1')
grid on
xlabel('Frecuencia en rad/s')
ylabel('Magnitud en dB')

figure
grid on
semilogx(frecuencias(1:round(length(TF_muestras_u1)/2))/Ts, mag2db(abs(TF_muestras_u1(1:round(length(TF_muestras_u1)/2))')))
title('Diagrama G(w) - Magnitud u1')
grid on
xlabel('Frecuencia en rad/s')
ylabel('Magnitud en dB')

figure
grid on
semilogx(frecuencias(1:round(length(TF_muestras_u1)/2))/Ts, 57.29*angle(TF_muestras_u1(1:round(length(TF_muestras_u1)/2))'))
title('Diagrama G(w) - Fase u1')
grid on
xlabel('Frecuencia en rad/s')
ylabel('Fase en grados sexagesimales')


figure
grid on
semilogx(frecuencias(1:round(length(disturbance_spectrum_muestras_u2)/2))/Ts, mag2db(abs(disturbance_spectrum_muestras_u2(1:round(length(disturbance_spectrum_muestras_u2)/2))')))
title('Diagrama Espectro de perturbaci髇 u2')
grid on
xlabel('Frecuencia en rad/s')
ylabel('Magnitud en dB')

figure
grid on
semilogx(frecuencias(1:round(length(coherence_spectrum_muestras_u2)/2))/Ts, mag2db(abs(coherence_spectrum_muestras_u2(1:round(length(coherence_spectrum_muestras_u2)/2))')))
title('Diagrama Espectro de coherencia u2')
grid on
xlabel('Frecuencia en rad/s')
ylabel('Magnitud en dB')

figure
grid on
semilogx(frecuencias(1:round(length(TF_muestras_u2)/2))/Ts, mag2db(abs(TF_muestras_u2(1:round(length(TF_muestras_u2)/2))')))
title('Diagrama G(w) - Magnitud u2')
grid on
xlabel('Frecuencia en rad/s')
ylabel('Magnitud en dB')

figure
grid on
semilogx(frecuencias(1:round(length(TF_muestras_u2)/2))/Ts, 57.29*angle(TF_muestras_u2(1:round(length(TF_muestras_u2)/2))'))
title('Diagrama G(w) - Fase u2')
grid on
xlabel('Frecuencia en rad/s')
ylabel('Fase en grados sexagesimales')

disp('Push any key to begin the identification routine'); pause

%Calcular la funci贸n de transferencia correspondiente

% Paso 1: Realizar estimadores de funciones de intercorrelaci贸n Ryy, Ryu, Ruu
N = length(y_PRBS);
Ryy = 1/N * xcorr(y_PRBS(:,1), circshift(y_PRBS(:,1), round(tau_indice/2)));
Ryu = 1/N * xcorr(y_PRBS(:,1), circshift(c, round(tau_indice/2)));
Ruu = 1/N * xcorr(c, circshift(c, round(tau_indice/2)));

[ry_s ~] = size(Ryy);

w = hanning(ry_s); % Ventana de Hanning

% Paso 2: Realizar estimadores de los espectros
% w = [zeros(ry_s,1); w; zeros(ry_s,1)];
Oyy = fft(Ryy.*w);
Oyu = fft(Ryu.*w);
Ouu = fft(Ruu.*w);

% Paso 3: Finalmente se encuentra la funci贸n de transferencia estimada

Gw_u1 = Oyu/Ouu;
disturbance_u1 = Oyy - abs(Oyu).^2/Ouu;
coherence_u1 = sqrt(abs(Oyu).^2/(Oyy'*Ouu));

length(Gw_u1)

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
% title('Espectro de perturbaci髇 u1')
% grid on
% xlabel('Frecuencia en Hz')
% ylabel('Magnitud en dB')

% figure
% semilogx(mag2db(abs(coherence_u1)));
% title('Espectro de coherencia u1')
% grid on
% xlabel('Frecuencia en Hz')
% ylabel('Magnitud en dB')


Ryy = 1/N * xcorr(y_PRBS(:,2), circshift(y_PRBS(:,2), round(tau_indice/2)));
Ryu = 1/N * xcorr(y_PRBS(:,2), circshift(c, round(tau_indice/2)));
Ruu = 1/N * xcorr(c, circshift(c, round(tau_indice/2)));

[ry_s ~] = size(Ryy);

w = hanning(ry_s); % Ventana de Hanning

% Paso 2: Realizar estimadores de los espectros
% w = [zeros(ry_s,1); w; zeros(ry_s,1)];
Oyy = fft(Ryy.*w);
Oyu = fft(Ryu.*w);
Ouu = fft(Ruu.*w);

% Paso 3: Finalmente se encuentra la funci贸n de transferencia estimada

Gw_u2 = Oyu/Ouu;
disturbance_u2 = Oyy - abs(Oyu).^2/Ouu;
coherence_u2 = sqrt(abs(Oyu).^2/(Oyy'*Ouu));

length(Gw_u2)

figure
semilogx(mag2db(abs(Gw_u2)));
title('Diagrama de Bode xcorr u2 - Magnitud')
grid on
xlabel('Frecuencia en Hz')
ylabel('Magnitud en dB')

figure
semilogx(57.29*angle(Gw_u2));
title('Diagrama de Bode xcorr u1 - Fase')
grid on
xlabel('Frecuencia en Hz')
ylabel('Fase en grados')

% figure
% semilogx(mag2db(abs(disturbance_u2)));
% title('Espectro de perturbaci髇 u2')
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
% title('Respuesta a PRBS - versi髇 filtrada con media m髒il de ventana tau')
% grid on
% xlabel('t')
% ylabel('Magnitud')