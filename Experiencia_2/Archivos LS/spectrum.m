function Phi = spectrum(a)
    Phi = zeros(length(a),1);
    index = 1;
    for omega=-pi:2*pi/length(a):pi
%         display(omega);
        Phi(index) = sum(a.*transpose(exp(-1i*omega*(-pi:2*pi/(length(a)-1):pi))));
        index = index + 1;
    end
end