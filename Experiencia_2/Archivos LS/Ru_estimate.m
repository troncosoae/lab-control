function R_u = Ru_estimate(tau, a, b, Ts, npts)
    R_u = 0;
    for i = 1 + round(tau/(2*Ts)):npts
        R_u = R_u + a(i)*b(i - round(tau/(2*Ts)))*(1/npts);
    end
end