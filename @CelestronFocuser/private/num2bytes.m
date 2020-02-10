        function bytearray=num2bytes(F,num,bytes)
            % assuming MSB first, i.e. big endian
            bytearray=zeros(1,bytes,'uint8');
            for i=bytes:-1:1
                p=2^(8*i-8);
                b=floor(num/p);
                bytearray(bytes-i+1)=b;
                num=num-b*p;
            end
        end
