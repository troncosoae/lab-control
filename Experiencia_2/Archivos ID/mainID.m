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
 
% Parametros para la identifiaci贸n:
echo off
Ts = 0.005;      
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

% prbs = @(N) randi([0 1], 1, N);
% periodo_PRBS = filter(b, a, prbs(tau_indice));
% entrada_PRBS = repmat(periodo_PRBS, 1, round(npts/tau_indice));
% c = entrada_PRBS';
divisiones_periodos = 2;

NumChannel = 1;
Period = npts/divisiones_periodos;
NumPeriod = round(npts/Period);
entrada_PRBS = idinput([Period,NumChannel,NumPeriod]);

tamano_ventana = Period/200;
b = (1/Period)*ones(1,NumPeriod);
a = 1;

u3 = [t, entrada_PRBS];
[t3,x3,y3] = sim('BlackBox',tfinal,[],u3);
y3 = detrend(y3);
y_PRBS = y3(1:round(length(y3(1:length(y3)-1 - mod(length(y3),10)))/divisiones_periodos)*round(divisiones_periodos));
y_aux = reshape(y_PRBS,divisiones_periodos,[]);
y_PRBS = mean(y_aux);
c = entrada_PRBS(1:length(y_PRBS))';
% y_PRBS = filter(b, a, y_PRBS_ant);
% y_PRBS = lowpass(y_PRBS,150,1e3);

%Calcular la funci贸n de transferencia correspondiente

% Paso 1: Realizar estimadores de funciones de intercorrelaci贸n Ryy, Ryu, Ruu
N = length(y_PRBS);
Ryy = 1/N * cconv(y_PRBS,conj(fliplr(y_PRBS)), N);
Ryu = 1/N * cconv(y_PRBS,conj(fliplr(c)), N);
Ruu = 1/N * cconv(c,conj(fliplr(c)), N);

% Paso 2: Realizar estimadores de los espectros
lados_ventana = round((length(Ryy) - tamano_ventana)/2);

w = hanning(tamano_ventana); % Ventana de Hanning
w = [zeros(lados_ventana, 1) ; w ; zeros(lados_ventana, 1)]';

%Oyy = zeros(length(Ryy), 1);
%Oyu = zeros(length(Ryu), 1);
%Ouu = zeros(length(Ruu), 1);

%yy = (Ryy.*w);
%yu = (Ryu.*w);
%uu = (Ryu.*w);

%for k = 0:length(Ryy)-1
%    frecuencia = 2*pi*k/N;
%    t1 = 0;
%    t2 = 0;
%    t3 = 0;
%    for tau = 1:NumPeriod
%        t1 = t1 + yy(1 + k)*exp(1i*frecuencia*tau);
%        t2 = t2 + yu(1 + k)*exp(1i*frecuencia*tau);
%        t3 = t3 + uu(1 + k)*exp(1i*frecuencia*tau);
%    end
%    Oyy(1 + k) = t1;
%    Oyu(1 + k) = t2;
%    Ouu(1 + k) = t3;
%end
 % esto es lo que hab韆 antes, hay que escribir la f髍mula del profe (14)
 % en Identificacion.pdf
Oyy = fft(Ryy.*w);
Oyu = fft(Ryu.*w);
Ouu = fft(Ruu.*w);
% Paso 3: Finalmente se encuentra la funci贸n de transferencia estimada

G = fftshift(Oyu./Ouu);
disturbance = fftshift(Oyy - abs(Oyu).^2./Ouu);
coherence = sqrt((Oyu.*conj(Oyu))./(Oyy.*Ouu));
diffmag = gradient(mag2db(abs(G)));
diffphase = gradient(57.29*angle(G));
xvect = (-1/(2*Ts):(divisiones_periodos/(Ts*npts)):1/(Ts*2)-(divisiones_periodos/(Ts*npts)));
figure
semilogx(xvect(1:length(diffmag)), [mag2db(abs(G(1:length(diffmag)))); mag2db(diffmag)]);
title('Diagrama de Bode - Magnitud')
grid on
xlabel('Frecuencia en Hz')
ylabel('Magnitud en dB')

figure
semilogx(xvect(1:length(diffphase)), [57.29*angle(G(1:length(diffphase))); mag2db(diffphase)]);
title('Diagrama de Bode - Fase')
grid on
xlabel('Frecuencia en Hz')
ylabel('Fase en grados')

figure
semilogx(-1/(2*Ts):(divisiones_periodos/(Ts*npts)):1/(Ts*2)-(divisiones_periodos/(Ts*npts)), mag2db(abs(disturbance)));
title('Espectro de perturbaci髇')
grid on
xlabel('Frecuencia en Hz')
ylabel('Magnitud en dB')

figure
semilogx(-1/(2*Ts):(divisiones_periodos/(Ts*npts)):1/(Ts*2)-(divisiones_periodos/(Ts*npts)), abs(coherence));
title('Espectro de coherencia')
grid on
xlabel('Frecuencia en Hz')
ylabel('Magnitud')

disp('Push any key to begin the identification routine'); pause

%Obtener bode por comando spa()
z = [y_PRBS' c];
G = tfest(z, 3, 3);
[G2 FIV] = spa(z);

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
[Cxy,F] = mscohere(y_PRBS,c,w);

figure 
plot(F,Cxy); title('Magnitude-Squared Coherence'); xlabel('Frequency (Hz)'); grid on




