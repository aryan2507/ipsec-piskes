// Copyright 2020 ETH Zurich
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"context"
	"encoding/hex"
	"fmt"
	"time"
	"os"
	"github.com/scionproto/scion/go/lib/addr"
	"github.com/scionproto/scion/go/lib/sciond"

	"github.com/scionproto/scion/go/drkeymockup/drkey"
	"github.com/scionproto/scion/go/drkeymockup/drkey/protocol"
	"github.com/scionproto/scion/go/drkeymockup/mockupsciond"
)

// var now = uint32(0)
var now = uint32(time.Now().Unix())

var srcIA, _ = addr.IAFromString("1-ff00:0:110")
var dstIA, _ = addr.IAFromString("1-ff00:0:111")
var srcHost = addr.HostFromIPStr("127.0.0.1")
var dstHost = addr.HostFromIPStr("127.0.0.2")


var sciondForClient = "172.20.0.23:30255"
var sciondForServer = "172.20.0.23:30255"


// Check just ensures the error is nil, or complains and quits
func check(e error) {
	if e != nil {
		panic(fmt.Sprintf("Fatal error: %v", e))
	}
}

type Client struct {
	sciond sciond.Connector
}

func NewClient(sciondPath string) Client {
	sciond, err := sciond.NewService(sciondPath).Connect(context.Background())
	check(err)
	return Client{
		sciond: sciond,
	}
}

func (c Client) HostKey(meta drkey.Lvl2Meta) drkey.Lvl2Key {
	ctx, cancelF := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancelF()

	// get L2 key: (slow path)
	key, err := mockupsciond.DRKeyGetLvl2Key(ctx, meta, now)
	check(err)
	return key
}

func ThisClientAndMeta() (Client, drkey.Lvl2Meta) {
	c := NewClient(sciondForClient)
	meta := drkey.Lvl2Meta{
		KeyType:  drkey.Host2Host,
		Protocol: "piskes",
		SrcIA:    srcIA,
		DstIA:    dstIA,
		SrcHost:  srcHost,
		DstHost:  dstHost,
	}
	return c, meta
}

type Server struct {
	sciond sciond.Connector
}

func NewServer(sciondPath string) Server {
	sciond, err := sciond.NewService(sciondPath).Connect(context.Background())
	check(err)
	return Server{
		sciond: sciond,
	}
}

func (s Server) dsForServer(meta drkey.Lvl2Meta) drkey.DelegationSecret {
	ctx, cancelF := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancelF()

	dsMeta := drkey.Lvl2Meta{
		KeyType:  drkey.AS2AS,
		Protocol: meta.Protocol,
		SrcIA:    meta.SrcIA,
		DstIA:    meta.DstIA,
	}
	lvl2Key, err := mockupsciond.DRKeyGetLvl2Key(ctx, dsMeta, now)
	check(err)
	//fmt.Printf(hex.EncodeToString(lvl2Key.Key))
	ds := drkey.DelegationSecret{
		Protocol: lvl2Key.Protocol,
		Epoch:    lvl2Key.Epoch,
		SrcIA:    lvl2Key.SrcIA,
		DstIA:    lvl2Key.DstIA,
		Key:      lvl2Key.Key,
	}
	return ds
}

func (s Server) HostKeyFromDS(meta drkey.Lvl2Meta, ds drkey.DelegationSecret) drkey.Lvl2Key {
	piskes := (protocol.KnownDerivations["piskes"]).(protocol.DelegatedDerivation)
	derived, err := piskes.DeriveLvl2FromDS(meta, ds)
	check(err)
	return derived
}

func (s Server) HostKey(meta drkey.Lvl2Meta) drkey.Lvl2Key {
	ds := s.dsForServer(meta)
	return s.HostKeyFromDS(meta, ds)
}

func ThisServerAndMeta() (Server, drkey.Lvl2Meta) {
	server := NewServer(sciondForServer)
	meta := drkey.Lvl2Meta{
		KeyType:  drkey.Host2Host,
		Protocol: "piskes",
		SrcIA:    srcIA,
		DstIA:    dstIA,
		SrcHost:  srcHost,
		DstHost:  dstHost,
	}
	return server, meta
}

func main() {
	comp:= os.Args[3] < os.Args[4]
	sciondForServer = os.Args[5]
        sciondForClient = os.Args[5]
        ITER_COUNT := 100
	if comp {
	var serverKey drkey.Lvl2Key
	srcIA, _ = addr.IAFromString(os.Args[1])
	dstIA, _= addr.IAFromString(os.Args[2])
	srcHost = addr.HostFromIPStr(os.Args[3])
	dstHost = addr.HostFromIPStr(os.Args[4])
	server, metaServer := ThisServerAndMeta()
        ds := server.dsForServer(metaServer)
        for i := 0; i < ITER_COUNT; i++ {
                serverKey = server.HostKeyFromDS(metaServer, ds)
        }
        fmt.Printf(hex.EncodeToString(serverKey.Key))
	} else {
	var clientKey drkey.Lvl2Key
	srcIA, _ = addr.IAFromString(os.Args[2])
        dstIA, _= addr.IAFromString(os.Args[1])
        srcHost = addr.HostFromIPStr(os.Args[4])
        dstHost = addr.HostFromIPStr(os.Args[3])
	client, metaClient := ThisClientAndMeta()
        for i := 0; i < ITER_COUNT; i++ {
              clientKey = client.HostKey(metaClient)
        }
	fmt.Printf(hex.EncodeToString(clientKey.Key))
	}
	
}
