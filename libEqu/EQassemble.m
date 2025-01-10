function feq = EQassemble(ndof, MA, Blin, Clin, Fmem, Fmoor, Fext)
         
disp('=========== SET UPs ============================================')
disp('------------------------------------------------')
disp('Mooring Force Model:: ')
    if exist('Fmoor')
        disp(Fmoor)
    else
        warning('Need to define an mooring type')
        Fmoor = @(x)zeros(ndof,1);
    end


disp('------------------------------------------------')
disp('Exitation Force Model:: ')
    if exist('Fext')
        disp(Fext)
    else
        warning('Need to define an excitation type')
        Fext = @(t,x)(zeros(ndof,1));
    end


disp('------------------------------------------------')
disp('Memory effect in time domain:: ')
    if exist('Fmem')
        disp(Fmem)
    else
        warning('Need to define a force representing memory effect')
        Fmem = @(t,x)(zeros(ndof,1));
    end
disp('------------------------------------------------')
disp('=========== END ================================================')



% === Equations of Motions ================================================
feq = @(t,x)( [zeros(ndof,ndof), eye(ndof,ndof);...
              -inv(MA)*Clin,    -inv(MA)*Blin]*x +...
              [zeros(ndof,1); inv(MA)*(Fext(t,x)-Fmem(t,x)+Fmoor(x))] );


end