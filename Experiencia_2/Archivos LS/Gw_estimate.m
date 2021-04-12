function [TF, dist_spect, coherence_spect] = Gw_estimate(w, tau_indice, entrada, y, npts, Ts, W)
    phi_PRBS_u = 0;
    phi_PRBS_yu = 0;
    phi_PRBS_y = 0;

    for j = 1:(tau_indice - 1)
        phi_PRBS_u = phi_PRBS_u + W(j)*Ru_estimate(j, entrada, entrada, Ts, npts)*exp(-1i*w*j);
    end
    for j = 1:(tau_indice - 1)
        phi_PRBS_yu = phi_PRBS_yu + W(j)*Ru_estimate(j, y, entrada, Ts, npts)*exp(-1i*w*j);
    end
    for j = 1:(tau_indice - 1)
        phi_PRBS_y = phi_PRBS_y + W(j)*Ru_estimate(j, y, y, Ts, npts)*exp(-1i*w*j);
    end

    TF = phi_PRBS_yu/phi_PRBS_u;
    dist_spect = phi_PRBS_y - (abs(phi_PRBS_yu)^2)/phi_PRBS_u;
    coherence_spect = sqrt((abs(phi_PRBS_yu)^2)/(phi_PRBS_y*phi_PRBS_u));
end