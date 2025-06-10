% make a long focuser stride, check the shape of the speed curve
a=abs(F.Limits -F.Pos);
if a(2)>a(1)
    t=F.Limits(2)-1000;
else
    t=F.Limits(1)+1000;
end

b=NaN(2,abs(F.Pos-t)); % just many more than likely needed
t0=now;
i=0;
F.Pos=t;
while strcmp(F.Status,'moving')
    i=i+1;
    b(2,i)=F.Pos;
    b(1,i)=(now-t0)*86400;
end

r=b(2,10:i-10)/[b(1,10:i-10);ones(1,i-19)];

plot(b(1,1:i),b(2,1:i),'.-',...
     b(1,1:i),b(1,1:i)*r(1)+r(2),'--')
grid on
xlabel('time, s'); ylabel('ticks')
title(sprintf('fitted slope = %f ticks/sec',r(1)))

