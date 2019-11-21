package main

import (
	"fmt"
	"log"
	"net"
	"os"

	impl "github.com/ivohutasoit/alira/chatting/service/impl"
	service "github.com/ivohutasoit/alira/common/service"
	"google.golang.org/grpc"
)

func main() {
	listen, err := net.Listen("tcp", ":9000")
	if err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)
		os.Exit(1)
	}

	// register service
	server := grpc.NewServer()
	service.RegisterChatServiceServer(server, impl.NewChatServiceServerImpl())
	// start gRPC server
	log.Println("starting server...")
	server.Serve(listen)
}
