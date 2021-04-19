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

toc
echo on
% Se presentan gráficos de las respuestas
echo off

% prbs = @(N) randi([0 1], 1, N);
% periodo_PRBS = filter(b, a, prbs(tau_indice));
% entrada_PRBS = repmat(periodo_PRBS, 1, round(npts/tau_indice));

divisiones_periodos = 4;
c_zero = 25;

NumChannel = 1;
Period = npts/divisiones_periodos;
NumPeriod = round(npts/Period);
% entrada_PRBS = idinput([Period,NumChannel,NumPeriod]);
prbs = @(N) randi([-1 1], 1, N);
% periodo_PRBS = filter(b, a, prbs(tau_indice));
periodo_PRBS = prbs(Period);
entrada_PRBS = transpose(repmat(periodo_PRBS, 1, NumPeriod));
% sim_PRBS = [t, entrada_PRBS, entrada_PRBS];
sim_PRBS = [t, entrada_PRBS, zeros(npts,1)];

% tamano_ventana = Period/25;
tamano_ventana = Period/50;

[t_PRBS,x,y3] = sim('loopshape',tfinal,[],sim_PRBS);
y_PRBS = y3(1:round(length(y3(1:length(y3)-1 - mod(length(y3),10)))/divisiones_periodos)*round(divisiones_periodos),:);
y_aux = reshape(y_PRBS(:,1),divisiones_periodos,[]);
y_PRBS1 = mean(y_aux);
y_aux = reshape(y_PRBS(:,2),divisiones_periodos,[]);
y_PRBS2 = mean(y_aux);
c = entrada_PRBS(1:length(y_PRBS1))';

%Calcular la función de transferencia correspondiente

% Paso 1: Realizar estimadores de funciones de intercorrelación Ryy, Ryu, Ruu
N = length(y_PRBS1);
% Ryy = 1/N * xcorr(y_PRBS(:,1), circshift(y_PRBS(:,1), round(tau_indice/2)));
% Ryu = 1/N * xcorr(y_PRBS(:,1), circshift(c, round(tau_indice/2)));
% Ruu = 1/N * xcorr(c, circshift(c, round(tau_indice/2)));
Ryy = 1/N * cconv(y_PRBS1,conj(fliplr(y_PRBS1)), N);
Ryu = 1/N * cconv(y_PRBS1,conj(fliplr(c)), N);
Ruu = 1/N * cconv(c,conj(fliplr(c)),N);

lados_ventana = round((length(Ryy) - tamano_ventana)/2);

w = hanning(tamano_ventana); % Ventana de Hanning
w = [zeros(lados_ventana, 1) ; w ; zeros(lados_ventana, 1)]';

% Paso 2: Realizar estimadores de los espectros
% w = [zeros(ry_s,1); w; zeros(ry_s,1)];
Oyy = fft(Ryy.*w);
Oyu = fft(Ryu.*w);
Ouu = fft(Ruu.*w);

% Paso 3: Finalmente se encuentra la función de transferencia estimada

Gw_u1 = fftshift(Oyu./Ouu);
disturbance_u1 = fftshift(Oyy - (Oyu.*conj(Oyu))./Ouu);
coherence_u1 = sqrt((Oyu.*conj(Oyu))./(Oyy.*Ouu));
% coherence_u1 = mscohere(y_PRBS1, c, w);
% coherence_u1 = sqrt((Oyu.*conj(Oyu))./(Oyy.*Ouu));
diffmag = diff(mag2db(abs(Gw_u1)));
diffphase = diff(-57.29*angle(Gw_u1));
xvect = -1/(2*Ts):(divisiones_periodos/(Ts*npts)):1/(Ts*2)-(divisiones_periodos/(Ts*npts));

figure 
Gx = Gw_u1./(1 + Gw_u1);
semilogx(xvect(1:length(diffmag)), mag2db(abs(Gx(1:length(diffmag)))));
title('Diagrama de Bode Gx - Magnitud')
grid on
xlabel('Frecuencia en Hz')
ylabel('Magnitud en dB')
figure
semilogx(xvect(1:length(diffphase)), -57.29*angle(Gx(1:length(diffphase))));
title('Diagrama de Bode Gx - Fase')
grid on
xlabel('Frecuencia en Hz')
ylabel('Fase en grados')

theta = -10*pi:(20*pi)*Ts:10*pi;
theta = theta(1:length(y_PRBS1));
figure
polarplot(theta,Gx(1:length(y_PRBS1)))
title("Polar plot transfer function Gx")

%%
figure
semilogx(xvect(1:length(diffmag)), [mag2db(abs(Gw_u1(1:length(diffmag))))]);
title('Diagrama de Bode cconv u1 - Magnitud')
grid on
xlabel('Frecuencia en Hz')
ylabel('Magnitud en dB')

figure
semilogx(xvect(1:length(diffphase)), [-57.29*angle(Gw_u1(1:length(diffphase)))]);
title('Diagrama de Bode cconv u1 - Fase')
grid on
xlabel('Frecuencia en Hz')
ylabel('Fase en grados')


%%
figure
semilogx(xvect(1:length(diffmag)), [mag2db(abs(Gw_u1(1:length(diffmag)))); mag2db(diffmag)]);
title('Diagrama de Bode cconv u1 - Magnitud')
grid on
xlabel('Frecuencia en Hz')
ylabel('Magnitud en dB')

figure
semilogx(xvect(1:length(diffphase)), [-57.29*angle(Gw_u1(1:length(diffphase))); mag2db(diffphase)]);
title('Diagrama de Bode cconv u1 - Fase')
grid on
xlabel('Frecuencia en Hz')
ylabel('Fase en grados')

figure
semilogx(-1/(2*Ts):(divisiones_periodos/(Ts*npts)):1/(Ts*2)-(divisiones_periodos/(Ts*npts)), mag2db(abs(disturbance_u1)));
title('Espectro de perturbaci�n u1')
grid on
xlabel('Frecuencia en Hz')
ylabel('Magnitud en dB')

figure
semilogx(abs(coherence_u1));
title('Espectro de coherencia u1')
grid on
xlabel('Frecuencia en Hz')
ylabel('Magnitud en dB')

% figure
% semilogx(-1/(2*Ts):(divisiones_periodos/(Ts*npts)):1/(Ts*2)-(divisiones_periodos/(Ts*npts)), abs(coherence_u1));
% title('Espectro de coherencia u1')
% grid on
% xlabel('Frecuencia en Hz')
% ylabel('Magnitud en dB')

%%
opts = bodeoptions('cstprefs');
opts.Title.String = 'Estimated transfer function u1';
opts.Title.FontSize = 12;
opts.FreqUnits = 'Hz';

figure
frdata = idfrd(Gw_u1,xvect,Ts);
bode(frdata, opts)

%%
theta = -10*pi:(20*pi)*Ts:10*pi;
theta = theta(1:length(y_PRBS1));
figure
polarplot(theta,Gw_u1(1:length(y_PRBS1)))
title("Polar plot transfer function u1")

%%
% Ryy = 1/N * xcorr(y_PRBS(:,2), circshift(y_PRBS(:,2), round(tau_indice/2)));
% Ryu = 1/N * xcorr(y_PRBS(:,2), circshift(c, round(tau_indice/2)));
% Ruu = 1/N * xcorr(c, circshift(c, round(tau_indice/2)));
N = length(y_PRBS2);
Ryy = 1/N * cconv(y_PRBS2,conj(fliplr(y_PRBS2)), N);
Ryu = 1/N * cconv(y_PRBS2,conj(fliplr(c)), N);
Ruu = 1/N * cconv(c,conj(fliplr(c)), N);

lados_ventana = round((length(Ryy) - tamano_ventana)/2);

w = hanning(tamano_ventana); % Ventana de Hanning
w = [zeros(lados_ventana, 1) ; w ; zeros(lados_ventana, 1)]';

% Paso 2: Realizar estimadores de los espectros
Oyy = fft(Ryy.*w);
Oyu = fft(Ryu.*w);
Ouu = fft(Ruu.*w);
% Paso 3: Finalmente se encuentra la función de transferencia estimada

Gw_u2 = fftshift(Oyu./Ouu);
disturbance_u2 = fftshift(Oyy - (Oyu.*conj(Oyu))./Ouu);
% coherence_u2 = sqrt((Oyu.*conj(Oyu))./(Oyy.*Ouu));
coherence_u2 = mscohere(y_PRBS2, c, w);
diffmag = gradient(mag2db(abs(Gw_u2)));
diffphase = gradient(57.29*angle(Gw_u2));
xvect = -1/(2*Ts):(divisiones_periodos/(Ts*npts)):1/(Ts*2)-(divisiones_periodos/(Ts*npts));

figure
semilogx(xvect(1:length(diffmag)), [mag2db(abs(Gw_u2(1:length(diffmag)))); mag2db(diffmag)]);
title('Diagrama de Bode cconv u2 - Magnitud')
grid on
xlabel('Frecuencia en Hz')
ylabel('Magnitud en dB')

figure
semilogx(xvect(1:length(diffphase)), [57.29*angle(Gw_u2(1:length(diffphase))); mag2db(diffphase)]);
title('Diagrama de Bode cconv u2 - Fase')
grid on
xlabel('Frecuencia en Hz')
ylabel('Fase en grados')

figure
semilogx(-1/(2*Ts):(divisiones_periodos/(Ts*npts)):1/(Ts*2)-(divisiones_periodos/(Ts*npts)), mag2db(abs(disturbance_u2)));
title('Espectro de perturbaci�n u2')
grid on
xlabel('Frecuencia en Hz')
ylabel('Magnitud en dB')

figure
semilogx(coherence_u2);
title('Espectro de coherencia u2')
grid on
xlabel('Frecuencia en Hz')
ylabel('Magnitud en dB')


%%
figure
polarplot(theta,Gw_u2)
title("Polat plot transfer function u2")

% figure
% semilogx(-1/(2*Ts):(divisiones_periodos/(Ts*npts)):1/(Ts*2)-(divisiones_periodos/(Ts*npts)), abs(coherence_u2));
% title('Espectro de coherencia u2')
% grid on
% xlabel('Frecuencia en Hz')
% ylabel('Magnitud en dB')

opts = bodeoptions('cstprefs');
opts.Title.String = 'Estimated transfer function u2';
opts.Title.FontSize = 12;
opts.FreqUnits = 'Hz';

figure
frdata = idfrd(Gw_u2,xvect,Ts);
bode(frdata, opts)

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