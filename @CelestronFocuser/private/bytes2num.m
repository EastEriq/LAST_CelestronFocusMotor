        function num=bytes2num(F,bytearray)
            % assuming the number is given MSB first
            num=double(bytearray(:))'*(2.^((length(bytearray)-1)*8:-8:0))';
        end
