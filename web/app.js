$(document).ready(function(){
    function updatePlayerHUD(data) {
        if (data.health <= 100) {
            $('#health-container').fadeIn('slow')
            $('#health').css('width', data.health+"%")
        } else { $('#health-container').fadeOut('slow') }

        if (data.armor >= 0) {
            $('#armor-container').fadeIn('slow')
            $('#armor').css('width', data.armor+"%")
        } else { $('#armor-container').fadeOut('slow') }

        if (data.thirst <= 100) {
            $('#thirst-container').fadeIn('slow')
            $('#thirst').css('width', data.thirst+"%")
        } else { $('#thirst-container').fadeOut('slow') }

        if (data.hunger <= 100) {
            $('#hunger-container').fadeIn('slow')
            $('#hunger').css('width', data.hunger+"%")
        } else { $('#hunger-container').fadeOut('slow') }

        if (data.stamina <= 100) {
            $('#stamina-container').fadeIn('slow')
            $('#stamina').css('width', data.stamina+"%")
        } else { $('#stamina-container').fadeOut('slow') }

        if (data.voice <= 1.5 ) {
            $('#voz-bg1').css('background-color', "rgba(212, 212, 212, 0.765)")
            $('#voz-bg1').css('opacity', "0.9")
            $('#voz-bg2').css('background-color', "rgba(0, 0, 0, 0.365)")
            $('#voz-bg3').css('background-color', "rgba(0, 0, 0, 0.365)")
            
        } else if (data.voice <= 3.0) {
            $('#voz-bg1').css('background-color', "rgba(212, 212, 212, 0.765)")
            $('#voz-bg2').css('background-color', "rgba(212, 212, 212, 0.765)")
            $('#voz-bg1').css('opacity', "0.9")
            $('#voz-bg2').css('opacity', "0.9")
            $('#voz-bg3').css('background-color', "rgba(0, 0, 0, 0.365)")
        } else if (data.voice <= 6.0) {
            $('#voz-bg1').css('background-color', "rgba(212, 212, 212, 0.765)")
            $('#voz-bg2').css('background-color', "rgba(212, 212, 212, 0.765)")
            $('#voz-bg3').css('background-color', "rgba(212, 212, 212, 0.765)")
        } else {
            $('#voz-bg1').css('background-color', "rgba(0, 0, 0, 0.365)")
        }

        if (data.talking) {
            if (data.voice <= 1.5) { 
                $('#voz-bg1').css('background-color', "rgba(255, 255, 0, 1)")
                $('#voz-bg2').css('background-color', "rgba(0, 0, 0, 0.365)")
                $('#voz-bg3').css('background-color', "rgba(0, 0, 0, 0.365)")
            } else if (data.voice <= 3.0) {
                $('#voz-bg1').css('background-color', "rgba(255, 255, 0, 1)")
                $('#voz-bg2').css('background-color', "rgba(255, 255, 0, 1)")
                $('#voz-bg3').css('background-color', "rgba(0, 0, 0, 0.365)")
            } else if (data.voice <= 7.0) {
                $('#voz-bg1').css('background-color', "rgba(255, 255, 0, 1)")
                $('#voz-bg2').css('background-color', "rgba(255, 255, 0, 1)")
                $('#voz-bg3').css('background-color', "rgba(255, 255, 0, 1)")
            } else {
                $('#voz-bg1').css('background-color', "rgba(212, 212, 212, 0.765)")
            }
        } 


    }


    function setSeatbelt(enable) {
        if (enable){
            /*$('#seatbelt').css('color','#00ffe7')*/
            $('#seatbelt').css('display', 'none');
        } else {
            $('#seatbelt').css('display', '');
            $('#seatbelt').css('color','rgb(248, 157, 157)')
        }
    }

    function updateVehicleHUD(data) {
        $('#speed').text(data.speed)

        $('#altitude').text(data.altitude)

        $('#alt-txt').text(data.altitudetexto)

        $('#fuel').text(data.fuel)

        if (data.gear == 0) {
            $('#gear').text('R')
        } else {
            $('#gear').text(data.gear)
        }

        $('#street1').text(data.street1)

        $('#street2').text(data.street2)
        
        $('#direction').text(data.direction)
        
        setSeatbelt(data.seatbelt)
    }

    
    


    window.addEventListener('message', function(event) {
        const data = event.data;
        if (data.action == 'showPlayerHUD') {
            $('body').fadeIn('slow')
        } else if (data.action == 'hidePlayerHUD') {
            $('body').fadeOut('slow')
        } else if (data.action == 'updatePlayerHUD') {
            updatePlayerHUD(data)
        } else if (data.action == 'showVehicleHUD') {
            $('#vehicle-hud-container').fadeIn('slow')
        } else if(data.action == 'hideVehicleHUD') {
            $('#vehicle-hud-container').fadeOut('slow')
        } else if (data.action == 'updateVehicleHUD') {
            updateVehicleHUD(data)
        } else if (data.action == 'setSeatbelt') {
            setSeatbelt(data.seatbelt)
        }
    })
});