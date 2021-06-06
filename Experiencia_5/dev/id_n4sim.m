%% definiciones

Ts_data_sink = 0.1;

%% identificación del sistema (varios ordenes)

% clear sys_ABCD sys_ABCDK;
data = data_2;
%%
% prueba varios ordenes
nx = 1:15;
sys_ABCDK = n4sid(data,nx);
compare(data,sys_ABCDK);

%%
sys_ABCDKx = n4sid(data,10);
compare(data,sys_ABCDKx);

%%
sys_ABCDK7 = n4sid(data,7);
compare(data,sys_ABCDK7);
%%
sys_ABCDK6 = n4sid(data,6);
compare(data,sys_ABCDK6);
%%
sys_ABCDK5 = n4sid(data,5);
compare(data,sys_ABCDK5);
%%
sys_ABCDK4 = n4sid(data,4);
compare(data,sys_ABCDK4);

%%
sys_ABCD = ss(sys_ABCDK.A, sys_ABCDK.B, sys_ABCDK.C, sys_ABCDK.D, Ts_data_sink);
compare(data,sys_ABCD);
