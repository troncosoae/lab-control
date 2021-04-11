function R = circ_corr(a,b,tau)
    R = zeros(tau_indice + 1,1);
    index = tau + round(tau_indice/2) + 1;
    R(index) = 1/length(a)*sum(a.*circshift(b, tau));
end