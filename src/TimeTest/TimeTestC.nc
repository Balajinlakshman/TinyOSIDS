/*
 * Copyright (c) 2008 Dimas Abreu Dutra
 * All rights reserved
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the Stanford University nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL DIMAS ABREU
 * DUTRA OR HIS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * @author Dimas Abreu Dutra
 */

#include "TestSerial2.h"
#include "message.h"
#include "../Reset/Reset.h"

configuration TimeTestC {
} implementation {
  components TimeTestP as App;

  components LedsC, MainC;
  components SerialActiveMessageC as AM;
  components new TimerMilliC();

  components new SerialAMSenderC(AM_TEST_SERIAL_MSG) as SerialTestSend;
  components new SerialAMReceiverC(AM_TEST_SERIAL_MSG) as SerialTestRecv;

  App.Boot -> MainC.Boot;
  App.Control -> AM;
//  App.Receive -> AM.Receive[AM_TEST_SERIAL_MSG];
  App.Receive -> SerialTestRecv;
//  App.AMSend -> AM.AMSend[AM_TEST_SERIAL_MSG];
  App.AMSend -> SerialTestSend;
  App.Leds -> LedsC;
  App.MilliTimer -> TimerMilliC;
  App.Packet -> AM;

// my extension
  components ActiveMessageC as AMR;
  App.ControlRadio -> AMR;

  components new AMReceiverC(AM_COMMANDMSG) as RadioCmdRecv;
  components new AMSenderC(AM_COMMANDMSG) as RadioCmdAMSend;

  components new SerialAMReceiverC(AM_COMMANDMSG) as UartCmdRecv;
  components new SerialAMSenderC(AM_COMMANDMSG) as UartCmdAMSend;  
  components ResetC;

  // keep alive send timer
  components new TimerMilliC() as AliveTimer;
  App.AliveTimer -> AliveTimer;

  components new TimerMilliC() as InitTimer;
  App.InitTimer -> InitTimer;
  
  App.UartCmdAMSend -> UartCmdAMSend;
  App.RadioCmdAMSend -> RadioCmdAMSend;
  App.Acks -> RadioCmdAMSend;

  App.UartCmdRecv -> UartCmdRecv;
  App.RadioCmdRecv -> RadioCmdRecv;

  App.Reset -> ResetC;
  
  // UART time synchronizer
  components TimeUARTSyncC as TimeUartSync;
  TimeUartSync.Boot -> MainC.Boot;
  App.TimeUARTCtl -> TimeUartSync;
  App.GlobalTime -> TimeUartSync;
  App.TimeUARTSyncInfo -> TimeUartSync;
  
  components new SerialAMSenderC(AM_TIMESYNCREPORT) as TimeSyncReportAMSend;
  App.TimeSyncReportAMSend -> TimeSyncReportAMSend;
  App.SerialAMPacket -> TimeSyncReportAMSend;
}
