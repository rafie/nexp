
(lots
	(lot nbu.prod.mcu
		(vobs
			nbu.prod.mcu)

		(lots
			nbu.mcu
			nbu.web
			nbu.media
			nbu.dsp
			nbu.infra
			nbu.bsp
			nbu.tools
			nbu.tests))

	(lot nbu.mcu
		(vobs
			mcu
			adapters
			dialingInfo
			mediaCtrlInfo
			nbu.proto.jingle-stack))

	(lot nbu.web
		(vobs
			web))

	(lot nbu.media
		(vobs
			nbu.media
			mvp
			mpc
			map
			mf
			mpInfra
			NBU_FEC
			NBU_RTP_RTCP_STACK
			NBU_ICE))

	(lot nbu.dsp
		(vobs
			dspIcsVideo
			dspInfra
			dspIntelInfra
			dspNetraInfra
			dspNetraVideo
			dspUCGW
			mpDsp
			NetraVideoCODEC
			swAudioCodecs))

	(lot nbu.tbu-stacks
		(vobs
			NBU_COMMON_CORE
			NBU_SIP_STACK
			NBU_H323_STACK))

	(lot nbu.infra
		(vobs
			nbu.infra
			boardInfra
			configInfra
			swInfra
			loggerInfra
			rvfc
			nbu.contrib))

	(lot nbu.build
		(vobs
			freemasonBuild))

	(lot nbu.tools
		(vobs
			nbu.tools))

	(lot nbu.bsp
		(vobs
			bspLinuxIntel
			bspLinuxARM))

	(lot nbu.tests
		(vobs
			nbu.test))
)
