%--------------------------------------------------------------
%     IEE2683 Laboratorio de Control Autom谩tico
%     Archivo Prueba Caja Negra
%
%     Jos茅 Moreno Rojas
%
%--------------------------------------------------------------

clear all
close all
clc;
echo on
% Se deben hacer pruebas con diferentes entradas.
echo off
disp('Push any key to begin the identification routine'); pause
tic
echo on
 
% Parametros para la identifiaci贸n:
echo off
Ts = 0.005     ;      
tfinal = 20;
t = (Ts:Ts:tfinal)';
npts = length(t);
echo on
 
% El modelo Simulink ser谩 simulado a continuaci贸n. Primero se construye la
% entrada del sistema y luego se usa la funci贸n sim para simular y capturar
% los valores de la salida.
echo off

tau = 0.2;
tau_indice = round(tau/Ts);
b = (1/tau_indice)*ones(1,tau_indice);
a = 1;

prbs = @(N) randi([0 1], 1, N);
periodo_PRBS = filter(b, a, prbs(tau_indice));
entrada_PRBS = repmat(periodo_PRBS, 1, round(npts/tau_indice));
c = entrada_PRBS';

u3 = [t, c];

[t3,x3,y3] = sim('BlackBox',tfinal,[],u3);

%Obtener bode por comando spa()
[x3 ~] = size(y3);
[x ~] = size(c);

c = [c; zeros(x3-x,1)];
z = [y3 c];
G = tfest(z, 3, 3);
[G2 FIV] = spa(z);

% figure(1)
% plot(t1,y1)
% title('Respuesta a u1')
% xlabel('t')
% ylabel('Magnitud')
% 
% figure(2)
% plot(t2,y2)
% title('Respuesta a u2')
% xlabel('t')
% ylabel('Magnitud')
% 
% figure(3)
% plot(t3,y3)
% title('Respuesta a u3')
% xlabel('t')
% ylabel('Magnitud')
% 
% figure(4)
% plot(t4,y4)
% title('Respuesta a u4')
% xlabel('t')
% ylabel('Magnitud')
% 
opts = bodeoptions('cstprefs');
opts.Title.String = 'Estimated transfer function (tfest)';
opts.Title.FontSize = 12;
opts.FreqUnits = 'Hz';

figure
b1 = bodeplot(G, opts);
showConfidence(b1,3)

figure
frecuencias = linspace(-10*pi,10*pi,npts);
[re,im,wout,sdre,sdim] = nyquist(G, frecuencias);
re = squeeze(re);
im = squeeze(im); 
sdre = squeeze(sdre);
sdim = squeeze(sdim);
plot(re,im,'b',re+3*sdre,im+3*sdim,'k:',re-3*sdre,im-3*sdim,'k:')
title('Nyquist plot of transfer function');
xlabel('Real Axis');
ylabel('Imaginary Axis');

opts = bodeoptions('cstprefs');
opts.Title.String = 'Estimated frequency response (spa)';
opts.Title.FontSize = 12;
opts.FreqUnits = 'Hz';

figure
b2 = bodeplot(G2, opts);
showConfidence(b2,3)

figure
spect = spectrumplot(G2);
showConfidence(spect,3)

w = hanning(round(tau_indice/2)); % Ventana de Hanning
[Cxy,F] = mscohere(y3,c,w);

figure 
plot(F,Cxy); title('Magnitude-Squared Coherence'); xlabel('Frequency (Hz)'); grid on

%Calcular la funci贸n de transferencia correspondiente

% Paso 1: Realizar estimadores de funciones de intercorrelaci贸n Ryy, Ryu, Ruu

Ryy = 1/N * cconv(y3,conj(fliplr(y3)), 2*length(y_PRBS));
Ryu = 1/N * cconv(y3,conj(fliplr(c)), 2*length(y_PRBS));
Ruu = 1/N * cconv(c,conj(fliplr(c)),2*length(y_PRBS));

[ry_s ~] = size(Ryy);

w = hanning(ry_s); % Ventana de Hanning

% Paso 2: Realizar estimadores de los espectros
z
% w = [zeros(ry_s,1); w; zeros(ry_s,1)];
Oyy = fft(Ryy.*w);
Oyu = fft(Ryu.*w);
Ouu = fft(Ruu.*w);

% Paso 3: Finalmente se encuentra la funci贸n de transferencia estimada

G = Oyu/Ouu;
disturbance = Oyy - abs(Oyu).^2/Ouu;
coherence = sqrt(abs(Oyu).^2/(Oyy'*Ouu));

figure
semilogx(mag2db(abs(G(1:round(length(G)/2)))));
title('Diagrama de Bode - Magnitud')
grid on
xlabel('Frecuencia en Hz')
ylabel('Magnitud en dB')

figure
semilogx(angle(57.29*G(1:round(length(G)/2))));
title('Diagrama de Bode - Fase')
grid on
xlabel('Frecuencia en Hz')
ylabel('Fase en grados')

figure
semilogx(mag2db(abs(disturbance(1:round(length(disturbance)/2)))));
title('Espectro de perturbaci髇')
grid on
xlabel('Frecuencia en Hz')
ylabel('Magnitud en dB')

figure
semilogx(mag2db(abs(coherence(1:round(length(coherence)/2)))));
title('Espectro de coherencia')
grid on
xlabel('Frecuencia en Hz')
ylabel('Magnitud en dB')





