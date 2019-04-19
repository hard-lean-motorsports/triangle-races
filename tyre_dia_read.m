function dia = tyre_dia_read(tyre_string)
    %tyre_dia_read This is simply a utility function to read tyre diameters and convert them to the correct units
    part = 1;
    tyre_num = [];
    tyre_unit = [];
    for i=1:length(tyre_string)
        if(isletter(tyre_string(i)))
            part = 2;
        end
        if(part == 1)
            tyre_num = [tyre_num, tyre_string(i)];
        else
            tyre_unit = [tyre_unit, tyre_string(i)];
        end
    end
    tyre_dia_unit = str2double(tyre_num);
    dia = conv_unit(tyre_dia_unit, tyre_unit, "m");
end

