RSpec.describe ROM::LDAP::Directory do

  context 'ApacheDS' do
    include_context 'vendor', 'apache_ds'

    subject { directory }

    it { is_expected.to be_sortable }

    it { is_expected.to be_pageable }

    it '#type returns symbol' do
      expect(directory.type).to eql(:apache_ds)
    end

    it '#vendor returns name and version' do
      expect(directory.vendor_name).to eql('Apache Software Foundation')
      expect(directory.vendor_version).to eql('2.0.0-M24')
      expect(directory.vendor).to eql(['Apache Software Foundation', '2.0.0-M24'])
    end

    it '#supported_mechanisms lists authentication protocols in order' do
      expect(directory.supported_mechanisms).to eql(%w[CRAM-MD5 DIGEST-MD5 GSS-SPNEGO GSSAPI NTLM SIMPLE])
    end

    it '#supported_features lists oids in order' do
      expect(directory.supported_features).to eql(%w[1.3.6.1.4.1.4203.1.5.1])
    end

    it '#capabilities translates oids' do
      expect(directory.capabilities.sort).to eql(%i[
        cascade
        directory_sync
        entry_change_notification
        manage_dsa_it
        paged_results
        password_policy_request
        permissive_modify
        persistent_search
        proxied_authorization_v2
        search_notification
        show_deleted
        sort_request
        sort_response
        subentries
        sync_done
        sync_info_message
        sync_request
        sync_state
        virtual_list_view_request
        virtual_list_view_response
      ])
    end

    it '#supported_extensions lists oids in order' do
      expect(directory.supported_extensions).to eql([
          '1.3.6.1.4.1.1466.20036',
          '1.3.6.1.4.1.1466.20037',
          '1.3.6.1.4.1.18060.0.1.3',
          '1.3.6.1.4.1.18060.0.1.5',
          '1.3.6.1.4.1.4203.1.11.1'
        ])
    end

    it '#supported_controls lists oids in order' do
      expect(directory.supported_controls).to eql([
          '1.2.840.113556.1.4.1413',
          '1.2.840.113556.1.4.319',
          '1.2.840.113556.1.4.417',
          '1.2.840.113556.1.4.473',
          '1.2.840.113556.1.4.474',
          '1.2.840.113556.1.4.528',
          '1.2.840.113556.1.4.841',
          '1.3.6.1.4.1.18060.0.0.1',
          '1.3.6.1.4.1.42.2.27.8.5.1',
          '1.3.6.1.4.1.4203.1.10.1',
          '1.3.6.1.4.1.4203.1.9.1.1',
          '1.3.6.1.4.1.4203.1.9.1.2',
          '1.3.6.1.4.1.4203.1.9.1.3',
          '1.3.6.1.4.1.4203.1.9.1.4',
          '2.16.840.1.113730.3.4.10',
          '2.16.840.1.113730.3.4.18',
          '2.16.840.1.113730.3.4.2',
          '2.16.840.1.113730.3.4.3',
          '2.16.840.1.113730.3.4.7',
          '2.16.840.1.113730.3.4.9'
        ])
    end

    it '#schema_object_classes lists known classes' do
      expect(directory.schema_object_classes).to include(
        "( 1.3.6.1.4.1.18055.0.4.1.3.1001 NAME 'reptilia' DESC 'Reptiles' SUP top STRUCTURAL MUST species MAY ( cn $ populationCount $ extinct ) X-SCHEMA 'wildlife' )")
    end

    it '#schema_attribute_types lists known attributes' do
      expect(directory.schema_attribute_types).to include(
        "( 1.3.6.1.4.1.18055.0.4.1.2.1005 NAME 'extinct' DESC 'Has the animal died out' EQUALITY booleanMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.7 SINGLE-VALUE USAGE userApplications X-SCHEMA 'wildlife' )")
    end
  end



  context '389DS' do
    include_context 'vendor', '389_ds'

    subject { directory }

    it { is_expected.to_not be_sortable }

    it { is_expected.to be_pageable }

    it '#vendor_name' do
      expect(directory.vendor_name).to eql('389 Project')
    end

    it '#vendor_version' do
      expect(directory.vendor_version).to match(/^389-Directory\/1.3.9.1 B[\d.]+$/)
    end

    it '#type' do
      expect(directory.type).to eql(:three_eight_nine)
    end

    it '#supported_extensions' do
      expect(directory.supported_extensions).to eql(%w[
        1.3.6.1.4.1.4203.1.11.1
        1.3.6.1.4.1.4203.1.11.3
        2.16.840.1.113730.3.5.12
        2.16.840.1.113730.3.5.3
        2.16.840.1.113730.3.5.4
        2.16.840.1.113730.3.5.5
        2.16.840.1.113730.3.5.6
        2.16.840.1.113730.3.5.7
        2.16.840.1.113730.3.5.8
        2.16.840.1.113730.3.5.9
        2.16.840.1.113730.3.6.5
        2.16.840.1.113730.3.6.6
        2.16.840.1.113730.3.6.7
        2.16.840.1.113730.3.6.8
      ])
    end

    it '#netscapemdsuffix' do
      expect(directory.netscapemdsuffix).to eql('cn=ldap://dc=rom,dc=ldap:389')
    end
  end



  context 'OpenDJ' do
    include_context 'vendor', 'open_dj'

    subject { directory }

    it { is_expected.to_not be_sortable }

    it { is_expected.to be_pageable }

    it '#vendor_name' do
      expect(directory.vendor_name).to eql('ForgeRock AS.')
    end

    it '#vendor_version' do
      expect(directory.vendor_version).to match(/^OpenDJ Server \d.\d.\d$/)
    end

    it '#type' do
      expect(directory.type).to eql(:open_dj)
    end

    it '#supported_extensions' do
      expect(directory.supported_extensions).to eql(%w[
        1.3.6.1.1.8
        1.3.6.1.4.1.1466.20037
        1.3.6.1.4.1.26027.1.6.1
        1.3.6.1.4.1.26027.1.6.2
        1.3.6.1.4.1.26027.1.6.3
        1.3.6.1.4.1.4203.1.11.1
        1.3.6.1.4.1.4203.1.11.3
      ])
    end

    it '#full_vendor_version' do
      expect(directory.full_vendor_version).to match(/^\d.\d.\d.[a-f0-9]+$/)
    end

    it '#etag' do
      expect(directory.etag).to match(/^[\da-f]{16}$/)
    end
  end



  context 'OpenLDAP' do
    include_context 'vendor', 'open_ldap'

    subject { directory }

    it { is_expected.to_not be_sortable }

    it { is_expected.to be_pageable }

    it '#vendor_name' do
      expect(directory.vendor_name).to eql('OpenLDAP')
    end

    it '#vendor_version' do
      expect(directory.vendor_version).to eql('0.0')
    end

    it '#organization' do
      expect(directory.organization).to eql('ROM-LDAP OpenLDAP Server')
    end

    it '#type' do
      expect(directory.type).to eql(:open_ldap)
    end

    it '#supported_extensions' do
      expect(directory.supported_extensions).to eql(%w[
        1.3.6.1.1.8
        1.3.6.1.4.1.4203.1.11.1
        1.3.6.1.4.1.4203.1.11.3
      ])
    end
  end


  if ENV['AD_URI']
    context 'Active Directory' do
      include_context 'directory'

      let(:uri) { ENV['AD_URI'] }
      let(:bind_dn) { ENV['AD_USER'] }
      let(:bind_pw) { ENV['AD_PW'] }

      it '#vendor_name' do
        expect(directory.vendor_name).to eql('Microsoft')
      end

      it '#vendor_version' do
        expect(directory.vendor_version).to eql('Windows Server 2008 R2 (6.1)')
      end

      it '#type' do
        expect(directory.type).to eql(:active_directory)
      end

      it '#supported_capabilities' do
        expect(directory.supported_capabilities).to eql(%w[
          1.2.840.113556.1.4.1670
          1.2.840.113556.1.4.1791
          1.2.840.113556.1.4.1935
          1.2.840.113556.1.4.2080
          1.2.840.113556.1.4.2237
          1.2.840.113556.1.4.800
        ])
      end

      it '#forest_functionality' do
        expect(directory.forest_functionality).to eql(4)
      end

      it '#directory_time' do
        expect(directory.directory_time).to be_an_instance_of(Time)
        expect(directory.directory_time).to be_within(3600*1).of(Time.now.utc)
      end
    end
  end

end
