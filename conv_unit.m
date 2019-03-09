function out = conv_unit(in, unit_from, unit_to)
    % conv_unit Converts between units.
    % Currently:
    % Nm lb-ft
    % kw hp
    % in mm m
    % G m/s^2
    % kph mph m/s
    % rpm rps rad/s
    % kg lb
    out = NaN;
    % Torque
    if(strcmpi(unit_from, "Nm"))
        if(strcmpi(unit_to, "lb-ft"))
            out = in * 1.35582;
        end
    elseif(strcmpi(unit_from, "lb-ft"))
        if(strcmpi(unit_to, "Nm"))
            out = in / 1.35582;
        end
    % Power
    elseif(strcmpi(unit_from, "kw"))
        if(strcmpi(unit_to, "hp"))
            out = in * 1.34102;
        end
    elseif(strcmpi(unit_from, "hp"))
        if(strcmpi(unit_to, "kw"))
            out = in / 1.34102;
        end
    % Length
    elseif(strcmpi(unit_from, "in"))
        if(strcmpi(unit_to, "mm"))
            out = in * 25.4;
        elseif(strcmpi(unit_to, "m"))
            out = in * 0.0254;
        end
    elseif(strcmpi(unit_from, "mm"))
        if(strcmpi(unit_to, "in"))
            out = in / 25.4;
        elseif(strcmpi(unit_to, "m"))
            out = in / 1000;
        end
    elseif(strcmpi(unit_from, "m"))
        if(strcmpi(unit_to, "in"))
            out = in / 0.0254;
        elseif(strcmpi(unit_to, "mm"))
            out = in * 1000;
        end
    % Accell
    elseif(strcmpi(unit_from, "G"))
        if(strcmpi(unit_to, "m/s^2"))
            out = in * 0.101971621;
        end
    elseif(strcmpi(unit_from, "m/s^2"))
        if(strcmpi(unit_to, "G"))
            out = in / 0.101971621;
        end
    % Speed
    elseif(strcmpi(unit_from, "m/s"))
        if(strcmpi(unit_to, "mph"))
            out = in * 2.23694;
        elseif(strcmpi(unit_to, "kph") || strcmpi(unit_to, "km/h"))
            out = in * 3.6;
        end
    elseif(strcmpi(unit_from, "mph"))
        if(strcmpi(unit_to, "m/s"))
            out = in / 2.23694;
        elseif(strcmpi(unit_to, "kph") || strcmpi(unit_to, "km/h"))
            out = in * 1.6;
        end
    elseif(strcmpi(unit_from, "kph") || strcmpi(unit_from, "km/h"))
        if(strcmpi(unit_to, "m/s"))
            out = in / 3.6;
        elseif(strcmpi(unit_to, "mph"))
            out = in / 1.6;
        end
    % periodicty
    elseif(strcmpi(unit_from, "rpm") || strcmpi(unit_from, "1/m"))
        if(strcmpi(unit_to, "rps") || strcmpi(unit_to, "1/s") || strcmpi(unit_to, "Hz"))
            out = in / 60;
        elseif(strcmpi(unit_to, "rad/s"))
            out = (2*pi*in) / 60;
        end
    elseif(strcmpi(unit_from, "rps") || strcmpi(unit_from, "1/s") || strcmpi(unit_from, "Hz"))
        if(strcmpi(unit_to, "rpm") || strcmpi(unit_to, "1/m"))
            out = in * 60;
        elseif(strcmpi(unit_to, "rad/s"))
            out = (2*pi*in);
        end
    elseif(strcmpi(unit_from, "rad/s"))
        if(strcmpi(unit_to, "rpm") || strcmpi(unit_to, "1/m"))
            out = (in * 60)/(2*pi);
        elseif(strcmpi(unit_to, "rps") || strcmpi(unit_to, "1/s") || strcmpi(unit_to, "Hz"))
            out = in / (2*pi);
        end
    % weight
    elseif(strcmpi(unit_from, "kg"))
        if(strcmpi(unit_to, "lb"))
            out = in * 2.2;
        end
    elseif(strcmpi(unit_from, "lb"))
        if(strcmpi(unit_to, "kg"))
            out = in / 2.2;
        end
    end
end