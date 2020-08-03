img = imread('lena.png');
i=Tarea2(img)
ee = ones(3,3);
i.dilatar(ee)
figure, imagesc(i.obtenerImagenOriginal)
figure, imagesc(i.obtenerImagenProcesada)