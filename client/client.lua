---@diagnostic disable: undefined-global
local VORPcore = exports.vorp_core:GetCore()
local BccUtils = exports['bcc-utils'].initiate()
local FeatherMenu =  exports['feather-menu'].initiate()


local CreatedBlips = {}
local CreatedNpcs = {}
local CreatedNewsStands = {}
local ZeitungOpen = false
local ArtikelOpen = false

Citizen.CreateThread(function()
local NewsMenuPrompt = BccUtils.Prompts:SetupPromptGroup()
    local newsprompt = NewsMenuPrompt:RegisterPrompt(_U('PromptName'), 0x760A9C6F, 1, 1, true, 'hold', {timedeventhash = 'MEDIUM_TIMED_EVENT'})
    if Config.NewsBlip then
        for h,v in pairs(Config.NewsLocations) do
        local newsblip = BccUtils.Blips:SetBlip(_U('BlipName'), 'blip_ambient_newspaper', 3.2, v.PrompCoords.x,v.PrompCoords.y,v.PrompCoords.z)
        CreatedBlips[#CreatedBlips + 1] = newsblip
        end
    end
    if Config.CreateStands then
        for h,v in pairs(Config.NewsLocations) do
        local Newsstand = BccUtils.Objects:Create('p_newsstand01x_new', v.StandCoords.x,v.StandCoords.y,v.StandCoords.z - 1, 0, true, 'standard')
        Newsstand:SetHeading(v.StandHeading)
        CreatedNewsStands[#CreatedNewsStands + 1] = Newsstand
        end
    end
    if Config.CreateNPC then
        for h,v in pairs(Config.NewsLocations) do
        local newsped = BccUtils.Ped:Create('A_M_O_SDUpperClass_01', v.NpcCoords.x, v.NpcCoords.y, v.NpcCoords.z -1, 0, 'world', false)
        CreatedNpcs[#CreatedNpcs + 1] = newsped
        newsped:Freeze()
        newsped:SetHeading(v.NpcHeading)
        newsped:Invincible()
        end
    end
    while true do
        Wait(1)
        for h,v in pairs(Config.NewsLocations) do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local dist = #(playerCoords - v.PrompCoords)
        if dist < 2 then
            NewsMenuPrompt:ShowGroup(_U('PromptName'))
            if Config.Show3dText then
            BccUtils.Misc.DrawText3D(v.PrompCoords.x, v.PrompCoords.y, v.PrompCoords.z, _U('ThreeDNewspaper'))
            end
            if newsprompt:HasCompleted() then
                TriggerEvent('mms-newspaper:client:opennewsmenu')
            end
        end
    end
    end
end)

RegisterNetEvent('mms-newspaper:client:opennewsmenu')
AddEventHandler('mms-newspaper:client:opennewsmenu',function()
    NewsMenu:Open({
        startupPage = NewsMenuPage1,
    })
end)


Citizen.CreateThread(function ()
    NewsMenu = FeatherMenu:RegisterMenu('NewsMenu', {
        top = '50%',
        left = '50%',
        ['720width'] = '500px',
        ['1080width'] = '700px',
        ['2kwidth'] = '700px',
        ['4kwidth'] = '8000px',
        style = {
            ['border'] = '5px solid orange',
            -- ['background-image'] = 'none',
            ['background-color'] = '#FF8C00'
        },
        contentslot = {
            style = {
                ['height'] = '250px',
                ['min-height'] = '50px'
            }
        },
        draggable = true,
    })
    NewsMenuPage1 = NewsMenu:RegisterPage('seite1')
    NewsMenuPage1:RegisterElement('header', {
        value = _U('MenuLabel'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    NewsMenuPage1:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    NewsMenuPage1:RegisterElement('button', {
        label = _('ReadNewspaper'),
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
        },
    }, function()
        TriggerEvent('mms-newspaper:client:readnewspaper')
    end)
    NewsMenuPage1:RegisterElement('button', {
        label = _('NewsPrice') .. Config.NewsPreis ..'$',
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
        },
    }, function()
        NewsMenuPage2:RouteTo()
    end)
    NewsMenuPage1:RegisterElement('button', {
        label = _U('DeleteMyNews'),
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
        },
    }, function()
        TriggerEvent('mms-newspaper:client:deleteinserat')
    end)
    NewsMenuPage1:RegisterElement('button', {
        label =  _U('CloseMenu'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        NewsMenu:Close({ 
        })
    end)
    NewsMenuPage1:RegisterElement('subheader', {
        value = _U('MenuLabel'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    NewsMenuPage1:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    }) 


    ---- Seite 2 Inserat Aufgeben

    NewsMenuPage2 = NewsMenu:RegisterPage('seite2')
    NewsMenuPage2:RegisterElement('header', {
        value = _U('InseratLabel'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    NewsMenuPage2:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    local inputTitle = ''
    NewsMenuPage2:RegisterElement('input', {
        label = _U('InputTitle'),
        placeholder = "",
        persist = false,
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
        }
    }, function(data)
        inputTitle = data.value
    end)
    local inputLink = ''
    NewsMenuPage2:RegisterElement('input', {
        label = _U('InputLink'),
        placeholder = "",
        persist = false,
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
        }
    }, function(data)
        inputLink = data.value
    end)
    local inputPn = ''
    NewsMenuPage2:RegisterElement('input', {
        label = _U('inputPn'),
        placeholder = "",
        persist = false,
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
        }
    }, function(data)
        inputPn = data.value
    end)
    NewsMenuPage2:RegisterElement('button', {
        label = _U('SaveEntry'),
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
        },
    }, function()
        TriggerEvent('mms-newspaper:client:registerinserat',inputTitle,inputLink,inputPn)
        NewsMenuPage1:RouteTo()
    end)
    NewsMenuPage2:RegisterElement('button', {
        label =  _U('CloseMenu'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        NewsMenu:Close({ 
        })
    end)
    NewsMenuPage2:RegisterElement('subheader', {
        value = _U('InseratLabel'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    NewsMenuPage2:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    }) 
end)

RegisterNetEvent('mms-newspaper:client:registerinserat')
AddEventHandler('mms-newspaper:client:registerinserat',function(inputTitle,inputLink,inputPn)
    TriggerServerEvent('mms-newspaper:client:registerinserat',inputTitle,inputLink,inputPn)
end)


RegisterNetEvent('mms-newspaper:client:readnewspaper')
AddEventHandler('mms-newspaper:client:readnewspaper',function()
    TriggerServerEvent('mms-newspaper:server:readnewspaper')
end)

RegisterNetEvent('mms-newspaper:client:deleteinserat')
AddEventHandler('mms-newspaper:client:deleteinserat',function ()
    TriggerServerEvent('mms-newspaper:server:deleteinserat')
end)


RegisterNetEvent('mms-newspaper:client:opennewspaper')
AddEventHandler('mms-newspaper:client:opennewspaper',function(newsentrys)
    if ZeitungOpen == false then
    NewsMenuPage3 = NewsMenu:RegisterPage('seite3')
    NewsMenuPage3:RegisterElement('header', {
        value = _U('ShowInseratLabel'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    NewsMenuPage3:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    for v, news in ipairs(newsentrys) do
        local Label = _U('Titel') .. news.title .. _U('From') .. news.firstname .. ' ' .. news.lastname
        local id = news.id
        local title = news.title
        local picture = news.picture
        local firstname = news.firstname
        local lastname = news.lastname
        local pn = news.pn
        NewsMenuPage3:RegisterElement('button', {
            label =  Label,
            style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
            },
        }, function()
            TriggerEvent('mms-newspaper:client:openartikel',id,title,picture,firstname,lastname,pn)
        end)
    end
    NewsMenuPage3:RegisterElement('button', {
        label = _('Back'),
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
        },
    }, function()
        NewsMenuPage1:RouteTo()
    end)
    NewsMenuPage3:RegisterElement('button', {
        label =  _U('CloseMenu'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        NewsMenu:Close({ 
        })
    end)
    NewsMenuPage3:RegisterElement('subheader', {
        value = _U('ShowInseratLabel'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    NewsMenuPage3:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    }) 
    ZeitungOpen = true
    NewsMenu:Open({
        startupPage = NewsMenuPage3,
    })

elseif ZeitungOpen == true then
    NewsMenuPage3:UnRegister()
    NewsMenuPage3 = NewsMenu:RegisterPage('seite3')
    NewsMenuPage3:RegisterElement('header', {
        value = _U('ShowInseratLabel'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    NewsMenuPage3:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    for v, news in ipairs(newsentrys) do
        local Label = _U('Titel') .. news.title .. _U('From') .. news.firstname .. ' ' .. news.lastname
        local id = news.id
        local title = news.title
        local picture = news.picture
        local firstname = news.firstname
        local lastname = news.lastname
        local pn = news.pn
        NewsMenuPage3:RegisterElement('button', {
            label =  Label,
            style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
            },
        }, function()
            TriggerEvent('mms-newspaper:client:openartikel',id,title,picture,firstname,lastname,pn)
        end)
    end
    NewsMenuPage3:RegisterElement('button', {
        label = _('Back'),
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
        },
    }, function()
        NewsMenuPage1:RouteTo()
    end)
    NewsMenuPage3:RegisterElement('button', {
        label =  _U('CloseMenu'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        NewsMenu:Close({ 
        })
    end)
    NewsMenuPage3:RegisterElement('subheader', {
        value = _U('ShowInseratLabel'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    NewsMenuPage3:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    }) 
    NewsMenu:Open({
        startupPage = NewsMenuPage3,
    })
end
end)

RegisterNetEvent('mms-newspaper:client:openartikel')
AddEventHandler('mms-newspaper:client:openartikel',function(id,title,picture,firstname,lastname,pn)
    if ArtikelOpen == false then
    NewsMenuPage4 = NewsMenu:RegisterPage('seite4')
    NewsMenuPage4:RegisterElement('header', {
        value = _U('ShowInseratLabel'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    NewsMenuPage4:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    NewsMenuPage4:RegisterElement("html", {
            slot = 'header',
            value = {
                [[
                    <img width="400px" height="400px" style="margin: 0 auto;" src="]] .. picture .. [[" />
                ]]
            }
        })
    Titel = NewsMenuPage4:RegisterElement('textdisplay', {
        value = _U('Titel') .. title,
        style = {}
        })
    Autor = NewsMenuPage4:RegisterElement('textdisplay', {
        value = _U('Autor') .. firstname .. ' ' .. lastname ..'.',
        style = {}
        })
    PostNumber = NewsMenuPage4:RegisterElement('textdisplay', {
        value = _U('PostNumber') .. pn,
        style = {}
        })
    NewsMenuPage4:RegisterElement('button', {
        label = _('Back'),
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
        },
    }, function()
        NewsMenuPage1:RouteTo()
    end)
    NewsMenuPage4:RegisterElement('button', {
        label =  _U('CloseMenu'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        NewsMenu:Close({ 
        })
    end)
    NewsMenuPage4:RegisterElement('subheader', {
        value = _U('ShowInseratLabel'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    NewsMenuPage4:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    }) 
    ArtikelOpen = true
    NewsMenu:Open({
        startupPage = NewsMenuPage4,
    })

elseif ArtikelOpen == true then
    NewsMenuPage4:UnRegister()
    NewsMenuPage4 = NewsMenu:RegisterPage('seite4')
    NewsMenuPage4:RegisterElement('header', {
        value = _U('ShowInseratLabel'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    NewsMenuPage4:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    NewsMenuPage4:RegisterElement("html", {
            slot = 'header',
            value = {
                [[
                    <img width="400px" height="400px" style="margin: 0 auto;" src="]] .. picture .. [[" />
                ]]
            }
        })
    Titel = NewsMenuPage4:RegisterElement('textdisplay', {
        value = _U('Titel') .. title,
        style = {}
        })
    Autor = NewsMenuPage4:RegisterElement('textdisplay', {
        value = _U('Autor') .. firstname .. ' ' .. lastname .. '.',
        style = {}
        })
    PostNumber = NewsMenuPage4:RegisterElement('textdisplay', {
        value = _U('PostNumber') .. pn,
        style = {}
        })
    NewsMenuPage4:RegisterElement('button', {
        label = _('Back'),
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
        },
    }, function()
        NewsMenuPage1:RouteTo()
    end)
    NewsMenuPage4:RegisterElement('button', {
        label =  _U('CloseMenu'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        NewsMenu:Close({ 
        })
    end)
    NewsMenuPage4:RegisterElement('subheader', {
        value = _U('ShowInseratLabel'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    NewsMenuPage4:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    }) 
    NewsMenu:Open({
        startupPage = NewsMenuPage4,
    })
end
end)

---- CleanUp on Resource Restart 


RegisterNetEvent('onResourceStop',function()
    for _, npcs in ipairs(CreatedNpcs) do
        npcs:Remove()
	end
    for _, blips in ipairs(CreatedBlips) do
        blips:Remove()
	end
    for _, stands in ipairs(CreatedNewsStands) do
        stands:Remove()
	end
end)