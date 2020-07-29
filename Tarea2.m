classdef Tarea2 < handle
    properties (Access=private)
        imOriginal;
        imProcesada;
    end
    methods
        function obj = Tarea2(im)
            obj.imOriginal = im;
            obj.imProcesada = zeros(size(obj.imOriginal));
        end
        
        function dilatar(obj, ee)
            [tamx, tamy, canal] = size(obj.imOriginal);
            [eex, eey] = size(ee); 
            eex = floor(eex/2);
            eey = floor(eey/2);
            %Anadido de bordes a la imagen original. Resultado => Ireplica.
            Ireplica = zeros(tamx+eex*2, tamy+eey*2, 3);
            for c=1:canal
                Ireplica(1+eex:tamx+eex, 1+eey:tamy+eey, c) = double(obj.imOriginal(:,:,c));
            end
            %Calculo distancias euclideanas de cada pixel al origen. Resultado => Idistancias.
            Idistancias = zeros(tamx+eex*2,tamy+eey*2);
            for x=1:tamx+eex*2
                for y=1:tamy+eey*2
                    Idistancias(x,y) = sqrt( (0-Ireplica(x,y,1))^2 + (0-Ireplica(x,y,2))^2 + (0-Ireplica(x,y,3))^2 );
                end
            end     
            %obj.imProcesada = uint8(Ireplica);
            %obj.imProcesada = Idistancias;
            
            Idilatada = zeros(tamx, tamy, 3);
            for x=1+eex:tamx+eex
                for y=1+eey:tamy+eey
                    ventana = Idistancias(x-eex:x+eex, y-eey:y+eey);
                    ventana = ventana.*ee;
                    minimo = max(ventana(:));
                    [cordX, cordY] = find(ventana == minimo);
                    if(numel(cordX) == 1) %Caso cuando solo hay un solo minimo.
                        Idilatada(x-eex, y-eex, 1) = obj.imOriginal(cordX(1), cordY(1), 1);
                        Idilatada(x-eex, y-eex, 2) = obj.imOriginal(cordX(1), cordY(1), 2);
                        Idilatada(x-eex, y-eex, 3) = obj.imOriginal(cordX(1), cordY(1), 3);
                    else %Caso en que hay mas de un minimo.
                        %Usar otras metricas. Proyeccion Ortogonal -
                        %Distancia al objetivo.
                    end
                end
            end
        end
        
        
        function img = obtenerImagenOriginal(obj)
            img = obj.imOriginal;
        end
        function img = obtenerImagenProcesada(obj)
            img = obj.imProcesada;
        end
    end
end