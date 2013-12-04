<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">

	<pluginGroups>
		<pluginGroup>org.codehaus.mojo</pluginGroup>
		<pluginGroup>com.yy.maven.plugin</pluginGroup>
		<pluginGroup>org.apache.maven.plugins</pluginGroup>
	</pluginGroups>
	
	<proxies>
	</proxies>

	<servers>
		<!-- START: pay.duowan.com -->
		<server>
			<id>releases</id>
			<username>deployment</username>
			<password>deployment</password>
		</server>
		<server>
			<id>snapshots</id>
			<username>deployment</username>
			<password>deployment</password>
		</server>
		<!-- END: pay.duowan.com -->

		<server>
			<id>release-server-deploy</id>
			<username>release</username>
			<password>duowan123</password>
		</server>
	</servers>

	<mirrors>
		<!-- END: pay.duowan.com -->
		<mirror>
			<!-- This sends everything else to /public --> 
			<id>releases</id> 
			<mirrorOf>central</mirrorOf> 
			<url>http://dev.game.yy.com/nexus/content/groups/public</url> 
		</mirror>
		<mirror>
			<!--This is used to direct the public snapshots repo in the profile below over to a different nexus group -->
			<id>snapshots</id>
			<mirrorOf>public-snapshots</mirrorOf> 
			<url>http://dev.game.yy.com/nexus/content/groups/public-snapshots</url> 
		</mirror>
		<!-- END: pay.duowan.com -->
	</mirrors>

	<profiles>
		<!-- START: pay.duowan.com -->
		<profile>
			<id>nexus</id>
			<repositories>
				<repository>
					<id>central</id>
					<url>http://central</url>
					<releases><enabled>true</enabled></releases>
					<snapshots><enabled>false</enabled></snapshots>
				</repository>
			</repositories>
			<pluginRepositories>
				<pluginRepository>
					<id>central</id>
					<url>http://central</url>
					<releases><enabled>true</enabled></releases>
					<snapshots><enabled>false</enabled></snapshots>
				</pluginRepository>
			</pluginRepositories>
		</profile>
		<profile>
			<!--this profile will allow snapshots to be searched when activated-->
			<id>public-snapshots</id>
			<repositories>
				<repository>
					<id>public-snapshots</id>
					<url>http://public-snapshots</url>
					<releases><enabled>false</enabled></releases>
					<snapshots><enabled>true</enabled></snapshots>
				</repository>
			</repositories>
			<pluginRepositories>
				<pluginRepository>
					<id>public-snapshots</id>
					<url>http://public-snapshots</url>
					<releases><enabled>false</enabled></releases>
					<snapshots><enabled>true</enabled></snapshots>
				</pluginRepository>
			</pluginRepositories>
		</profile>
		<profile>
			<id>yy</id>
			<repositories>
				<repository>
					<id>nexus-public-repo</id>
					<name>nexus public repository</name>
					<url>http://jrepo.yypm.com:8181/nexus/content/groups/public</url>
					<releases>
						<enabled>true</enabled>
					</releases>
					<snapshots>
						<enabled>false</enabled>
					</snapshots>
				</repository>
				<repository>
					<id>yy-internal-releases</id>
					<name>yy internal releases</name>
					<url>http://jrepo.yypm.com:8181/nexus/content/repositories/releases</url>
					<releases>
						<enabled>true</enabled>
					</releases>
					<snapshots>
						<enabled>false</enabled>
					</snapshots>
				</repository>
				<repository>
					<id>yy-internal-snapshots</id>
					<name>yy internal snapshots</name>
					<url>http://jrepo.yypm.com:8181/nexus/content/repositories/snapshots</url>
					<releases>
						<enabled>false</enabled>
					</releases>
					<snapshots>
						<enabled>true</enabled>
					</snapshots>
				</repository>
			</repositories>

			<pluginRepositories>
				<pluginRepository>
					<id>nexus-public-repo</id>
					<name>nexus public repository</name>
					<url>http://jrepo.yypm.com:8181/nexus/content/groups/public</url>
					<releases>
						<enabled>true</enabled>
					</releases>
					<snapshots>
						<enabled>false</enabled>
					</snapshots>
				</pluginRepository>
				<pluginRepository>
					<id>yy-plugin-releases</id>
					<name>yy plugin releases</name>
					<url>http://jrepo.yypm.com:8181/nexus/content/repositories/releases</url>
					<releases>
						<enabled>true</enabled>
					</releases>
					<snapshots>
						<enabled>false</enabled>
					</snapshots>
				</pluginRepository>
				<pluginRepository>
					<id>yy-plugin-snapshots</id>
					<name>yy plugin snapshots</name>
					<url>http://jrepo.yypm.com:8181/nexus/content/repositories/snapshots</url>
					<releases>
						<enabled>false</enabled>
					</releases>
					<snapshots>
						<enabled>true</enabled>
					</snapshots>
				</pluginRepository>
			</pluginRepositories>
		</profile>
	</profiles>

	<activeProfiles>
		<activeProfile>yy</activeProfile>
		<!-- START: pay.duowan.com -->
		<activeProfile>nexus</activeProfile>
		<activeProfile>public-snapshots</activeProfile>
		<!-- END: pay.duowan.com -->
	</activeProfiles>

</settings>
