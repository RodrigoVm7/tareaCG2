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
                    ventanaImagen = double(Ireplica(x-eex:x+eex, y-eey:y+eey,:));
                    ventana = Idistancias(x-eex:x+eex, y-eey:y+eey);
                    ventana = ventana.*ee;
                    maximo = max(ventana(:));
                    [cordX, cordY] = find(ventana == maximo);
                    %Busqueda de un maximo a traves de las distancias eulideanas
                    if(numel(cordX) == 1) %Caso cuando solo hay un solo minimo.
                        Idilatada(x-eex, y-eey, 1) = ventanaImagen(cordX(1), cordY(1), 1);
                        Idilatada(x-eex, y-eey, 2) = ventanaImagen(cordX(1), cordY(1), 2);
                        Idilatada(x-eex, y-eey, 3) = ventanaImagen(cordX(1), cordY(1), 3);
                    else
                        %Caso en que hay mas de un minimo.
                        %Uso de la Proyeccion Ortogonal.
                        vectorDistancias = [];
                        for k=1: numel(cordX)      %recorremos los puntos minimos encontrados
                            puntoR3= [ventanaImagen(cordX(k), cordY(k), 1), ventanaImagen(cordX(k), cordY(k), 2), ventanaImagen(cordX(k), cordY(k), 3)]; %obtenemos el punto original (RGB)
                            coef= puntoR3(1) + puntoR3(2) + puntoR3(3);     
                            xEcuacion= coef/3;
                            vectorDistancias(k)= sqrt( (xEcuacion-puntoR3(1))^2 + (xEcuacion-puntoR3(2))^2 + (xEcuacion-puntoR3(3))^2 );  %guardamos las distancias calculadas 
                        end
                        cantidadMinimos = find(vectorDistancias == min(vectorDistancias(:)));   %averiguamos la cantidad de distancias minimas.
                        if(numel(cantidadMinimos) == 1) %Caso cuando hay una distancia maxima de la proyeccion ortogonal.
                            Idilatada(x-eex, y-eey, 1) = ventanaImagen(cordX(cantidadMinimos(1)), cordY(cantidadMinimos(1)), 1);
                            Idilatada(x-eex, y-eey, 2) = ventanaImagen(cordX(cantidadMinimos(1)), cordY(cantidadMinimos(1)), 2);
                            Idilatada(x-eex, y-eey, 3) = ventanaImagen(cordX(cantidadMinimos(1)), cordY(cantidadMinimos(1)), 3);
                        else
                            % caso en que hay mas de una distancia maxima.
                            %Distancia al punto de interes...
                            distanciasPuntoInteres = [];
                            for k=1:numel(cantidadMaximos)
                                puntoR3 = [ventanaImagen(cordX(cantidadMaximos(k)), cordY(cantidadMaximos(k)), 1), ventanaImagen(cordX(cantidadMaximos(k)), cordY(cantidadMaximos(k)), 2), ventanaImagen(cordX(cantidadMaximos(k)), cordY(cantidadMaximos(k)), 3)];
                                distanciasPuntoInteres(k) = sqrt( (ventanaImagen(1+eex,1+eey,1)-puntoR3(1))^2 + (ventanaImagen(1+eex,1+eey,2)-puntoR3(2))^2 + (ventanaImagen(1+eex,1+eey,3)-puntoR3(3))^2 );
                            end
                            minPtoInteres = find(distanciasPuntoInteres == min(distanciasPuntoInteres(:)));
                            Idilatada(x-eex, y-eey, 1) = ventanaImagen(cordX(minPtoInteres(1)), cordY(minPtoInteres(1)), 1);
                            Idilatada(x-eex, y-eey, 2) = ventanaImagen(cordX(minPtoInteres(1)), cordY(minPtoInteres(1)), 2);
                            Idilatada(x-eex, y-eey, 3) = ventanaImagen(cordX(minPtoInteres(1)), cordY(minPtoInteres(1)), 3);
                        end
                    end
                end
            end
            obj.imProcesada = uint8(Idilatada);
        end
        
        
        function img = obtenerImagenOriginal(obj)
            img = obj.imOriginal;
        end
        function img = obtenerImagenProcesada(obj)
            img = obj.imProcesada;
        end
    end
end