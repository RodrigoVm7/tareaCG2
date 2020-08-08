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
                        vectorMinimos = find(vectorDistancias == min(vectorDistancias(:)));   %averiguamos distancias minimas.
                        
                        if(numel(vectorMinimos) == 1) %Caso cuando hay una distancia maxima de la proyeccion ortogonal.
                            Idilatada(x-eex, y-eey, 1) = ventanaImagen(cordX(vectorMinimos(1)), cordY(vectorMinimos(1)), 1);
                            Idilatada(x-eex, y-eey, 2) = ventanaImagen(cordX(vectorMinimos(1)), cordY(vectorMinimos(1)), 2);
                            Idilatada(x-eex, y-eey, 3) = ventanaImagen(cordX(vectorMinimos(1)), cordY(vectorMinimos(1)), 3);
                        else
                            % caso en que hay mas de una distancia maxima.
                            %Distancia al punto de interes...
                            distanciasPuntoInteres = [];    
                            for k=1:numel(vectorMinimos)
                                puntoR3 = [ventanaImagen(cordX(vectorMinimos(k)), cordY(vectorMinimos(k)), 1), ventanaImagen(cordX(vectorMinimos(k)), cordY(vectorMinimos(k)), 2), ventanaImagen(cordX(vectorMinimos(k)), cordY(vectorMinimos(k)), 3)];
                                distanciasPuntoInteres(k) = sqrt( (ventanaImagen(1+eex,1+eey,1)-puntoR3(1))^2 + (ventanaImagen(1+eex,1+eey,2)-puntoR3(2))^2 + (ventanaImagen(1+eex,1+eey,3)-puntoR3(3))^2 );
                            end
                            minPtoInteres = find(distanciasPuntoInteres == min(distanciasPuntoInteres(:)));
                            if(numel(minPtoInteres) == 1)
                                Idilatada(x-eex, y-eey, 1) = ventanaImagen(cordX(minPtoInteres(1)), cordY(minPtoInteres(1)), 1);
                                Idilatada(x-eex, y-eey, 2) = ventanaImagen(cordX(minPtoInteres(1)), cordY(minPtoInteres(1)), 2);
                                Idilatada(x-eex, y-eey, 3) = ventanaImagen(cordX(minPtoInteres(1)), cordY(minPtoInteres(1)), 3);
                            else  %criterio LEXICOGRAFICO
                                
                                if(ventanaImagen(eex+1,eey+1, 1) > ventanaImagen(eex+1,eey+1, 2) && ventanaImagen(eex+1,eey+1, 2) > ventanaImagen(eex+1,eey+1, 3))  % Si el R>G>B del pixel central
                                    disp('primer criterio lexicografico');
                                    maxCanalR=0;  % Maximo en canal R
                                    maxCanalG=0;   % Maximo en canal G
                                    maxCandidatosR=[]; % Candidatos maximos en R
                                    maxCandidatosG=[]; % Candidatos maximos en G

                                    for m=1:numel(minPtoInteres)   %Para cada candidato de distancia al punto de interes
                                        if(ventanaImagen(cordX(minPtoInteres(m)), cordY(minPtoInteres(m)),1) == maxCanalR)  %Si el R del pixel de la ventana es igual al maximo encontrado
                                            maxCandidatosR(numel(maxCandidatosR)+1)= m; %Se guarda la posicion donde se encontro el candidato en el array de candidatos
                                        elseif(ventanaImagen(cordX(minPtoInteres(m)), cordY(minPtoInteres(m)),1) > maxCanalR) % %Si el R del pixel de la ventana es mayor al maximo encontrado
                                            maxCandidatoR = []; % Se vacia el array de candidatos
                                            maxCandidatoR(numel(maxCandidatosR)+1) = m; % %Se guarda la posicion donde se encontro el candidato en el array de candidatos
                                            maxCanalR = ventanaImagen(cordX(minPtoInteres(m)), cordY(minPtoInteres(m)),1); % Se actualiza el nuevo maximo en R
                                        end
                                    end

                                    if(numel(maxCandidatosR) == 1) % Si es el unico candidato se guarda en la imagen resultante
                                        Idilatada(x-eex, y-eey, 1) = ventanaImagen(cordX(minPtoInteres(maxCandidatosR(1))), cordY(minPtoInteres(maxCandidatosR(1))), 1);
                                        Idilatada(x-eex, y-eey, 2) = ventanaImagen(cordX(minPtoInteres(maxCandidatosR(1))), cordY(minPtoInteres(maxCandidatosR(1))), 2);
                                        Idilatada(x-eex, y-eey, 3) = ventanaImagen(cordX(minPtoInteres(maxCandidatosR(1))), cordY(minPtoInteres(maxCandidatosR(1))), 3);
                                    else
                                        for l=1:numel(maxCandidatosR) %Por cada candidato que tenga el R como maximo
                                            if(ventanaImagen(cordX(minPtoInteres(maxCandidatosR(l))),cordY(minPtoInteres(maxCandidatosR(l))),2) == maxCanalG)
                                                maxCandidatosG(numel(maxCandidatosG)+1)= l;
                                            elseif(ventanaImagen(cordX(minPtoInteres(maxCandidatosR(l))), cordY(minPtoInteres(maxCandidatosR(l))),2) > maxCanalG)
                                                maxCandidatoG = [];
                                                maxCandidatoG(numel(maxCandidatosG)+1) = l;
                                                maxCanalG = ventanaImagen(cordX(minPtoInteres(maxCandidatosR(l))), cordY(minPtoInteres(maxCandidatosR(l))),2);
                                            end
                                        end
                                        Idilatada(x-eex, y-eey, 1) = ventanaImagen(cordX(minPtoInteres(maxCandidatosR(maxCandidatosG(1)))), cordY(minPtoInteres(maxCandidatosR(maxCandidatosG(1)))), 1);
                                        Idilatada(x-eex, y-eey, 2) = ventanaImagen(cordX(minPtoInteres(maxCandidatosR(maxCandidatosG(1)))), cordY(minPtoInteres(maxCandidatosR(maxCandidatosG(1)))), 2);
                                        Idilatada(x-eex, y-eey, 3) = ventanaImagen(cordX(minPtoInteres(maxCandidatosR(maxCandidatosG(1)))), cordY(minPtoInteres(maxCandidatosR(maxCandidatosG(1)))), 3);

                                    end
                                else
                                    puntoIhsv= rgb2hsv(ventanaImagen(eex+1,eey+1, 1), ventanaImagen(eex+1,eey+1, 2), ventanaImagen(eex+1,eey+1, 3));  % convetir el punto original (rgb) a hsv
                                    distanciasHsv=[];
                                    for j=1: numel(minPtoInteres)     %convertimos los puntos minimos encontrados a hsv y luego calculamos las distncias al punto de interes tambien convertido
                                        candidatoHsv= rgb2hsv(ventanaImagen(cordX(minPtoInteres(j)), cordY(minPtoInteres(j)),1), ventanaImagen(cordX(minPtoInteres(j)), cordY(minPtoInteres(j)),2), ventanaImagen(cordX(minPtoInteres(j)), cordY(minPtoInteres(j)),3));
                                        distanciasHsv(j)= sqrt( (candidatoHsv(1)-puntoIhsv(1))^2 + (candidatoHsv(2)-puntoIhsv(2))^2 + (candidatoHsv(3)-puntoIhsv(3))^2); 
                                    end
                                    minHsv= find(distanciasHsv== min( distanciasHsv(:)));  %por mientras selecciona la menor distancia en hsv
                                    Idilatada(x-eex, y-eey, 1) = ventanaImagen(cordX(minPtoInteres(minHsv(1))), cordY(minPtoInteres(minHsv(1))), 1);
                                    Idilatada(x-eex, y-eey, 2) = ventanaImagen(cordX(minPtoInteres(minHsv(1))), cordY(minPtoInteres(minHsv(1))), 2);
                                    Idilatada(x-eex, y-eey, 3) = ventanaImagen(cordX(minPtoInteres(minHsv(1))), cordY(minPtoInteres(minHsv(1))), 3);
                             
                                end
%                                  ---- Fin elemento Lexicografico ----
                            end
                        end
                    end
                end
            end
            obj.imProcesada = uint8(Idilatada);
        end
        
        function erosionar(obj, ee)
            [tamx, tamy, canal] = size(obj.imOriginal);
            [eex, eey] = size(ee); 
            eex = floor(eex/2);
            eey = floor(eey/2);
            %Anadido de bordes a la imagen original. Resultado => Ireplica.
            Ireplica = ones(tamx+eex*2, tamy+eey*2, 3)*255;
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
            
            Ierosionada = zeros(tamx, tamy, 3);
            for x=1+eex:tamx+eex
                for y=1+eey:tamy+eey
                    ventanaImagen = double(Ireplica(x-eex:x+eex, y-eey:y+eey,:));
                    ventana = Idistancias(x-eex:x+eex, y-eey:y+eey);
                    ventana = ventana.*ee;
                    minimo = min(ventana(:));
                    [cordX, cordY] = find(ventana == minimo);
                    %Busqueda de un maximo a traves de las distancias eulideanas
                    if(numel(cordX) == 1) %Caso cuando solo hay un solo minimo.
                        Ierosionada(x-eex, y-eey, 1) = ventanaImagen(cordX(1), cordY(1), 1);
                        Ierosionada(x-eex, y-eey, 2) = ventanaImagen(cordX(1), cordY(1), 2);
                        Ierosionada(x-eex, y-eey, 3) = ventanaImagen(cordX(1), cordY(1), 3);
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
                        vectorMinimos = find(vectorDistancias == min(vectorDistancias(:)));   %averiguamos distancias minimas.
                        if(numel(vectorMinimos) == 1) %Caso cuando hay una distancia maxima de la proyeccion ortogonal.
                            Ierosionada(x-eex, y-eey, 1) = ventanaImagen(cordX(vectorMinimos(1)), cordY(vectorMinimos(1)), 1);
                            Ierosionada(x-eex, y-eey, 2) = ventanaImagen(cordX(vectorMinimos(1)), cordY(vectorMinimos(1)), 2);
                            Ierosionada(x-eex, y-eey, 3) = ventanaImagen(cordX(vectorMinimos(1)), cordY(vectorMinimos(1)), 3);
                        else
                            % caso en que hay mas de una distancia maxima.
                            %Distancia al punto de interes...
                            distanciasPuntoInteres = [];    
                            for k=1:numel(vectorMinimos)
                                puntoR3 = [ventanaImagen(cordX(vectorMinimos(k)), cordY(vectorMinimos(k)), 1), ventanaImagen(cordX(vectorMinimos(k)), cordY(vectorMinimos(k)), 2), ventanaImagen(cordX(vectorMinimos(k)), cordY(vectorMinimos(k)), 3)];
                                distanciasPuntoInteres(k) = sqrt( (ventanaImagen(1+eex,1+eey,1)-puntoR3(1))^2 + (ventanaImagen(1+eex,1+eey,2)-puntoR3(2))^2 + (ventanaImagen(1+eex,1+eey,3)-puntoR3(3))^2 );
                            end
                            minPtoInteres = find(distanciasPuntoInteres == min(distanciasPuntoInteres(:)));
                            if(numel(minPtoInteres) == 1)
                                Ierosionada(x-eex, y-eey, 1) = ventanaImagen(cordX(minPtoInteres(1)), cordY(minPtoInteres(1)), 1);
                                Ierosionada(x-eex, y-eey, 2) = ventanaImagen(cordX(minPtoInteres(1)), cordY(minPtoInteres(1)), 2);
                                Ierosionada(x-eex, y-eey, 3) = ventanaImagen(cordX(minPtoInteres(1)), cordY(minPtoInteres(1)), 3);
                            else  %criterio lexicografico
                                % Caso en el que el `pixel central tiene R > G > B 
                                if(ventanaImagen(eex+1,eey+1, 1) > ventanaImagen(eex+1,eey+1, 2) && ventanaImagen(eex+1,eey+1, 2) > ventanaImagen(eex+1,eey+1, 3))  % Si el R>G>B del pixel central
                                    
                                    maxCanalR=0;  % Maximo en canal R
                                    maxCanalG=0;   % Maximo en canal G
                                    maxCandidatosR=[]; % Candidatos maximos en R
                                    maxCandidatosG=[]; % Candidatos maximos en G

                                    for m=1:numel(minPtoInteres)   %Para cada candidato de distancia al punto de interes

                                        if(ventanaImagen(cordX(minPtoInteres(m)), cordY(minPtoInteres(m)),1) == maxCanalR)  %Si el R del pixel de la ventana es igual al maximo encontrado
                                            maxCandidatosR(numel(maxCandidatosR)+1)= m; %Se guarda la posicion donde se encontro el candidato en el array de candidatos
                                        elseif(ventanaImagen(cordX(minPtoInteres(m)), cordY(minPtoInteres(m)),1) > maxCanalR) % %Si el R del pixel de la ventana es mayor al maximo encontrado
                                            maxCandidatoR = []; % Se vacia el array de candidatos
                                            maxCandidatoR(numel(maxCandidatosR)+1) = m; % %Se guarda la posicion donde se encontro el candidato en el array de candidatos
                                            maxCanalR = ventanaImagen(cordX(minPtoInteres(m)), cordY(minPtoInteres(m)),1); % Se actualiza el nuevo maximo en R
                                        else
                                        end

                                    end

                                    if(numel(maxCandidatosR) == 1) % Si es el unico candidato se guarda en la imagen resultante
                                        Ierosionada(x-eex, y-eey, 1) = ventanaImagen(cordX(minPtoInteres(maxCandidatosR(1))), cordY(minPtoInteres(maxCandidatosR(1))), 1);
                                        Ierosionada(x-eex, y-eey, 2) = ventanaImagen(cordX(minPtoInteres(maxCandidatosR(1))), cordY(minPtoInteres(maxCandidatosR(1))), 2);
                                        Ierosionada(x-eex, y-eey, 3) = ventanaImagen(cordX(minPtoInteres(maxCandidatosR(1))), cordY(minPtoInteres(maxCandidatosR(1))), 3);
                                    else
                                        for l=1:numel(maxCandidatosR) %Por cada candidato que tenga el R como maximo
                                            if(ventanaImagen(cordX(minPtoInteres(maxCandidatosR(l))),cordY(minPtoInteres(maxCandidatosR(l))),2) == maxCanalG)
                                                maxCandidatosG(numel(maxCandidatosG)+1)= l;

                                            elseif(ventanaImagen(cordX(minPtoInteres(maxCandidatosR(l))), cordY(minPtoInteres(maxCandidatosR(l))),2) > maxCanalG)
                                                maxCandidatoG = [];
                                                maxCandidatoG(numel(maxCandidatosG)+1) = l;
                                                maxCanalG = ventanaImagen(cordX(minPtoInteres(maxCandidatosR(l))), cordY(minPtoInteres(maxCandidatosR(l))),2);
                                            else
                                            end
                                        end
                                        
                                            Ierosionada(x-eex, y-eey, 1) = ventanaImagen(cordX(minPtoInteres(maxCandidatosR(maxCandidatosG(1)))), cordY(minPtoInteres(maxCandidatosR(maxCandidatosG(1)))), 1);
                                            Ierosionada(x-eex, y-eey, 2) = ventanaImagen(cordX(minPtoInteres(maxCandidatosR(maxCandidatosG(1)))), cordY(minPtoInteres(maxCandidatosR(maxCandidatosG(1)))), 2);
                                            Ierosionada(x-eex, y-eey, 3) = ventanaImagen(cordX(minPtoInteres(maxCandidatosR(maxCandidatosG(1)))), cordY(minPtoInteres(maxCandidatosR(maxCandidatosG(1)))), 3);
                                      
                                    end
                                else
                                    puntoIhsv= rgb2hsv(ventanaImagen(eex+1,eey+1, 1), ventanaImagen(eex+1,eey+1, 2), ventanaImagen(eex+1,eey+1, 3));  % convetir el punto original (rgb) a hsv
                                    distanciasHsv=[];
                                    for j=1: numel(minPtoInteres)     %convertimos los puntos minimos encontrados a hsv y luego calculamos las distncias al punto de interes tambien convertido
                                        candidatoHsv= rgb2hsv(ventanaImagen(cordX(minPtoInteres(j)), cordY(minPtoInteres(j)),1), ventanaImagen(cordX(minPtoInteres(j)), cordY(minPtoInteres(j)),2), ventanaImagen(cordX(minPtoInteres(j)), cordY(minPtoInteres(j)),3));
                                        distanciasHsv(j)= sqrt( (candidatoHsv(1)-puntoIhsv(1))^2 + (candidatoHsv(2)-puntoIhsv(2))^2 + (candidatoHsv(3)-puntoIhsv(3))^2); 
                                    end

                                    minHsv= find(distanciasHsv== min( distanciasHsv(:)));  %por mientras selecciona la menor distancia en hsv
                                    Ierosionada(x-eex, y-eey, 1) = ventanaImagen(cordX(minPtoInteres(minHsv(1))), cordY(minPtoInteres(minHsv(1))), 1);
                                    Ierosionada(x-eex, y-eey, 2) = ventanaImagen(cordX(minPtoInteres(minHsv(1))), cordY(minPtoInteres(minHsv(1))), 2);
                                    Ierosionada(x-eex, y-eey, 3) = ventanaImagen(cordX(minPtoInteres(minHsv(1))), cordY(minPtoInteres(minHsv(1))), 3);
                                end
                            end
                        end
                    end
                end
            end
            obj.imProcesada = uint8(Ierosionada);
        end
        
        
        function img = obtenerImagenOriginal(obj)
            img = obj.imOriginal;
        end
        function img = obtenerImagenProcesada(obj)
            img = obj.imProcesada;
        end
    end
end