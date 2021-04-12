function TF = Gw_estimate(w, tau_indice, entrada, y, npts, Ts, W)
    phi_PRBS = 0;
    phi_PRBS_yu = 0;

    for j = 1:(tau_indice - 1)
        phi_PRBS = phi_PRBS + W(j)*Ru_estimate(j, entrada, entrada, Ts, npts)*exp(-1i*w*j);
    end
    for j = 1:(tau_indice - 1)
        phi_PRBS_yu = phi_PRBS_yu + W(j)*Ru_estimate(j, y, entrada, Ts, npts)*exp(-1i*w*j);
    end

    TF = phi_PRBS_yu/phi_PRBS;
end