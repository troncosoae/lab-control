%% estimacion de Kp y Kt

phi = 8.386e-1;
d_phi = 1.524e0;
theta = 2.824-1;
d_theta = 6.562e-2;
w_p = 5.459;
w_t = 8.14;
i_p = 6.586e-2;
i_t = 4.364e-2;

u_p = 1;
u_t = 1;

M_ext_vec = [
    -eps_e*d_phi; 
    -eps_t*d_theta];
M_ext_matrix = [
    -L_e*abs(w_p)*w_p 0;
    d*abs(w_p)*w_p*sin(phi) L_t*abs(w_t)*w_t];

M_ext_eval = eval(Mg*g + Tc*d_q2 + J*d_Omega);

xxx = M_ext_matrix\(M_ext_eval - M_ext_vec);